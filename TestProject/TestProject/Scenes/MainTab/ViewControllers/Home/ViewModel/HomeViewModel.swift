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
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let loadMoreSubject = PublishSubject<Void>()
    private let sectionModelsRelay = PublishRelay<[HomeSectionModel]>()
    private var isLoadedDone: Bool = false

    init(_ dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(
            loadData: loadDataSubject.asObserver(),
            loadMore: loadMoreSubject.asObserver()
        )
        output = Output(sectionModels: sectionModelsRelay.asObservable())

        transform()
    }

    func transform() {
        loadDataSubject
            .withUnretained(self)
            .flatMap { owner, _ in owner.dependency.api.rx.request(.getHomeData).asObservable() }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                guard let response = try? result.map(HomeResponse.self) else { return }

                let goodsItems = self.goodsListToHomeItem(response.goods)
                self.isLoadedDone = false
                let sectionModel = HomeSectionModel(
                    items: [.banner(.init(.init(banners: response.banners)))] + goodsItems
                )
                self.sectionModelsRelay.accept([sectionModel])
            })
            .disposed(by: disposeBag)

        loadMoreSubject
            .withUnretained(self)
            .filter { owner, _ in !owner.isLoadedDone }
            .withLatestFrom(sectionModelsRelay)
            .map { sectionModels -> Int? in sectionModels.first?.lastGoodsId() }
            .filterNil()
            .withUnretained(self)
            .flatMap { owner, lastId in owner.dependency.api.rx.request(.getGoodsList(lastId: lastId)) }
            .withLatestFrom(sectionModelsRelay) { ($0, $1) }
            .subscribe { [weak self] result, sectionModels in
                guard let self = self else { return }
                guard let section = sectionModels.first else { return }
                guard let response = try? result.map(GoodsListResponse.self) else { return }

                let goodsItems = self.goodsListToHomeItem(response.goods)
                self.isLoadedDone = goodsItems.count == 0

                guard goodsItems.isNotEmpty else { return }
                let newSection = HomeSectionModel(items: section.items + goodsItems)
                self.sectionModelsRelay.accept([newSection])
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension HomeViewModel {

    private func goodsListToHomeItem(_ goodsList: [Goods]) -> [HomeItem] {
        goodsList.map {
            let goods = $0.with {
                $0.isFavorite = FavoriteGoodsManager.shared.isFavoriteGoods($0.id)
            }
            let viewModel = GoodsCellViewModel(.init(isFavoriteEnabled: true, goods: goods))
            self.bindGoodsCellViewModel(viewModel)
            return .goods(viewModel)
        }
    }

    private func bindGoodsCellViewModel(_ viewModel: GoodsCellViewModel) {
        viewModel.output.favoriteTapped
            .withLatestFrom(sectionModelsRelay) { ($0, $1) }
            .map { [weak self] goods, sectionModels -> [HomeSectionModel]? in
                guard let section = sectionModels.first else { return nil }
                guard let goodsIndex = section.getGoodsCellViewModelIndex(viewModel) else { return nil }

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
                var newItems: [HomeItem] = section.items
                newItems[goodsIndex] = .goods(newViewModel)
                let newSection: HomeSectionModel = HomeSectionModel(items: newItems)
                return [newSection]
            }
            .filterNil()
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)
    }
}
