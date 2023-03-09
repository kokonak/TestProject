//
//  HomeViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//  
//

import RxSwift
import RxCocoa

final class HomeViewModel: ViewModel {

    struct Dependency {

    }

    struct Input {
        let loadData: AnyObserver<Void>
    }

    struct Output {
        let sectionModels: Observable<[HomeSectionModel]>
    }


    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let sectionModelsRelay = PublishRelay<[HomeSectionModel]>()

    init(_ dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(loadData: loadDataSubject.asObserver())
        output = Output(sectionModels: sectionModelsRelay.asObservable())

        transform()
    }

    func transform() {
        let banner: HomeItem = .banner(.init(.init(banners: Banner.dummies)))
        let goodsList: [HomeItem] = Goods.dummies.map {
            let viewModel = GoodsCellViewModel(.init(isFavoriteEnabled: true, goods: $0))
            self.bindGoodsCellViewModel(viewModel)
            return .goods(viewModel)
        }

        loadDataSubject
            .map { [.init(items: [banner] + goodsList)] }
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension HomeViewModel {

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
