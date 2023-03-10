//
//  MainTabViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//  
//

import RxSwift
import RxCocoa

final class MainTabViewModel: ViewModel {

    struct Dependency {

    }

    struct Input {
        let loadData: AnyObserver<Void>
    }

    struct Output {
        let tabs: Observable<[TabModel]>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataRelay = PublishSubject<Void>()
    private let tabsRelay = PublishRelay<[TabModel]>()

    init(_ dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(loadData: loadDataRelay.asObserver())
        output = Output(tabs: tabsRelay.asObservable())

        transform()
    }

    func transform() {
        loadDataRelay
            .map { TabModel.allCases }
            .bind(to: tabsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension MainTabViewModel {

}
