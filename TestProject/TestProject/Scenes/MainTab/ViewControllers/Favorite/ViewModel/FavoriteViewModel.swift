//
//  FavoriteViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//  
//

import RxSwift
import RxCocoa



final class FavoriteViewModel: ViewModel {

    struct Dependency {

    }

    struct Input {
        let loadData: AnyObserver<Void>
    }

    struct Output {
        let goods: Observable<[GoodsCellViewModel]>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let goodsRelay = PublishRelay<[GoodsCellViewModel]>()

    init(_ dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(loadData: loadDataSubject.asObserver())
        output = Output(goods: goodsRelay.asObservable())
        transform()
    }

    func transform() {
        loadDataSubject
            .map { Goods.dummies.map { .init(.init(isFavoriteEnabled: false, goods: $0)) } }
            .bind(to: goodsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension FavoriteViewModel {

}
