//
//  HomeViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//  
//

import RxSwift
import RxCocoa
import Moya
import RxMoya
import Foundation

final class HomeViewModel: ViewModel {

    struct Dependency {
        var api = MoyaProvider<HomeAPI>()
    }

    struct Input {
        let loadData: AnyObserver<Void>
        let loadMore: AnyObserver<Void>
    }

    struct Output {
        let sectionModels: Observable<[HomeSectionModel]>
        let stopRefreshing: Observable<Void>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let loadMoreSubject = PublishSubject<Void>()
    private let sectionModelsRelay = PublishRelay<[HomeSectionModel]>()
    private let stopRefreshingRelay = PublishRelay<Void>()
    private var isLoadedDone: Bool = false

    init(_ dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(
            loadData: loadDataSubject.asObserver(),
            loadMore: loadMoreSubject.asObserver()
        )
        output = Output(
            sectionModels: sectionModelsRelay.asObservable(),
            stopRefreshing: stopRefreshingRelay.asObservable()
        )

        transform()
    }

    func transform() {
        let homeResponseRelay = PublishRelay<ResponseType<HomeResponse>>()

        loadDataSubject
            .withUnretained(self)
            .flatMap { owner, _ in owner.dependency.api.rx.request(.getHomeData, of: HomeResponse.self) }
            .bind(to: homeResponseRelay)
            .disposed(by: disposeBag)

        homeResponseRelay
            .compactMap { $0.getSuccess() }
            .withUnretained(self)
            .map { owner, response in
                owner.isLoadedDone = false
                let sectionModel = HomeSectionModel(
                    bannerViewModel: HomeBannerCellViewModel(.init(banners: response.banners)),
                    items: owner.getGoodsCellViewModels(response.goods)
                )
                return [sectionModel]
            }
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)

        homeResponseRelay
            .map { _ in () }
            .bind(to: stopRefreshingRelay)
            .disposed(by: disposeBag)

        let goodsResponseRelay = PublishRelay<ResponseType<GoodsListResponse>>()

        loadMoreSubject
            .withUnretained(self)
            .filter { owner, _ in !owner.isLoadedDone }
            .withLatestFrom(sectionModelsRelay)
            .compactMap { $0.last?.lastGoodsId }
            .withUnretained(self)
            .flatMap { owner, lastId in
                owner.dependency.api.rx.request(.getGoodsList(lastId: lastId), of: GoodsListResponse.self)
            }
            .bind(to: goodsResponseRelay)
            .disposed(by: disposeBag)

        goodsResponseRelay
            .compactMap { $0.getSuccess() }
            .withLatestFrom(sectionModelsRelay) { ($0, $1) }
            .compactMap { [weak self] response, sectionModels -> [HomeSectionModel]? in
                guard let self = self else { return nil }
                guard let section = sectionModels.first else { return nil }

                self.isLoadedDone = response.goods.count == 0

                guard response.goods.isNotEmpty else { return nil }
                let newSection = HomeSectionModel(
                    bannerViewModel: section.bannerViewModel,
                    items: section.items + self.getGoodsCellViewModels(response.goods)
                )
                return [newSection]
            }
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension HomeViewModel {

    private func getGoodsCellViewModels(_ goodsList: [Goods]) -> [GoodsCellViewModel] {
        goodsList.map {
            let goods = $0.with {
                $0.isFavorite = FavoriteGoodsManager.shared.isFavoriteGoods($0.id)
            }
            let viewModel = GoodsCellViewModel(.init(isFavoriteEnabled: true, goods: goods))
            self.bindGoodsCellViewModel(viewModel)
            return viewModel
        }
    }

    private func bindGoodsCellViewModel(_ viewModel: GoodsCellViewModel) {
        viewModel.output.favoriteTapped
            .withLatestFrom(sectionModelsRelay) { ($0, $1) }
            .map { [weak self] goods, sectionModels -> [HomeSectionModel]? in
                guard let section = sectionModels.first else { return nil }
                guard let goodsIndex = section.items.firstIndex(
                    where: { viewModel.dependency.goods.id == $0.dependency.goods.id }
                ) else {
                    return nil
                }

                let oldGoods = viewModel.dependency.goods

                let newGoods = oldGoods.with {
                    $0.isFavorite = !oldGoods.isFavorite
                }

                if newGoods.isFavorite {
                    FavoriteGoodsManager.shared.addGoods(newGoods)
                } else {
                    FavoriteGoodsManager.shared.removeGoods(newGoods)
                }

                let newViewModel = GoodsCellViewModel(.init(isFavoriteEnabled: true, goods: newGoods))
                self?.bindGoodsCellViewModel(newViewModel)
                var newItems = section.items
                newItems[goodsIndex] = newViewModel
                let newSection = HomeSectionModel(bannerViewModel: section.bannerViewModel, items: newItems)
                return [newSection]
            }
            .filterNil()
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)
    }
}
