//
//  HomeBannerCellViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//  
//

import Foundation
import RxSwift
import RxCocoa

final class HomeBannerCellViewModel: ViewModel {

    struct Dependency {
        let banners: [Banner]
    }

    struct Input {
        let loadData: AnyObserver<Void>
    }

    struct Output {
        let banners: Observable<[Banner]>
    }


    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let bannersRelay = PublishRelay<[Banner]>()

    init(_ dependency: Dependency) {
        self.dependency = dependency
        input = Input(loadData: loadDataSubject.asObserver())
        output = Output(banners: bannersRelay.asObservable())

        transform()
    }

    func transform() {
        loadDataSubject
            .withUnretained(self)
            .map { owner, _ in owner.dependency.banners }
            .distinctUntilChanged()
            .bind(to: bannersRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension HomeBannerCellViewModel {

}
