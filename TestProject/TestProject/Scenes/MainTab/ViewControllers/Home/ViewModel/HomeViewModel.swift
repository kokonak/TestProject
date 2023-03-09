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
        let goodsList: [HomeItem] = Goods.dummies.map { .goods(.init(.init(isFavoriteEnabled: true, goods: $0))) }

        loadDataSubject
            .map { [.init(items: [banner] + goodsList)] }
            .bind(to: sectionModelsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension HomeViewModel {

}
