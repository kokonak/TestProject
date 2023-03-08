//
//  BannerViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//  
//

import RxSwift
import RxCocoa



final class BannerViewModel: ViewModel {
    
    struct Dependency {
    }
    
    struct Input {
        let banners: AnyObserver<[Banner]>
        let currentBannerIndex: AnyObserver<Int>
    }
    
    struct Output {
        let banners: Observable<[Banner]>
        let bannerCountText: Observable<String>
        let isBannerCountHidden: Observable<Bool>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let bannersSubject = PublishSubject<[Banner]>()
    private let currentBannerIndexSubject = PublishSubject<Int>()
    private let bannersRelay = PublishRelay<[Banner]>()
    private let bannerCountTextRelay = PublishRelay<String>()
    private let isBannerCountHiddenRelay = PublishRelay<Bool>()
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        input = Input(
            banners: bannersSubject.asObserver(),
            currentBannerIndex: currentBannerIndexSubject.asObserver()
        )
        output = Output(
            banners: bannersRelay.asObservable(),
            bannerCountText: bannerCountTextRelay.asObservable(),
            isBannerCountHidden: isBannerCountHiddenRelay.asObservable()
        )

        transform()
    }
    
    func transform() {
        bannersSubject
            .withUnretained(self)
            .map { owner, banners in owner.setExtraBanner(banners)}
            .bind(to: bannersRelay)
            .disposed(by: disposeBag)

        bannersSubject
            .filter { $0.count > 0 }
            .map { "1/\($0.count)" }
            .bind(to: bannerCountTextRelay)
            .disposed(by: disposeBag)

        bannersSubject
            .map { $0.count <= 1}
            .bind(to: isBannerCountHiddenRelay)
            .disposed(by: disposeBag)

        currentBannerIndexSubject
            .withLatestFrom(bannersRelay) { ($0, $1) }
            .map { currentIndex, banners in
                guard banners.count > 1 else { return currentIndex }

                let index: Int
                switch currentIndex {
                    case 0:
                        index = banners.count - 2
                    case banners.count - 1:
                        index = 1
                    default:
                        index = currentIndex
                }
                return index
            }
            .withLatestFrom(bannersSubject.asObservable()) { ($0, $1) }
            .map { "\($0.0)/\($0.1.count)" }
            .bind(to: bannerCountTextRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension BannerViewModel {

    private func setExtraBanner(_ banners: [Banner]) -> [Banner] {
        guard banners.count > 1 else { return banners }
        guard let first = banners.first else { return banners }
        guard let last = banners.last else { return banners }

        return [[last], banners, [first]].flatMap { $0 }
    }
}
