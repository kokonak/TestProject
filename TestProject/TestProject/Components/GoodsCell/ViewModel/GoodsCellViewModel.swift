//
//  GoodsCellViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//  
//

import Foundation
import RxSwift
import RxRelay

final class GoodsCellViewModel: ViewModel {
    
    struct Dependency {
        let isFavoriteEnabled: Bool
        let goods: Goods
    }
    
    struct Input {
        let loadData: AnyObserver<Void>
        let favoriteTap: AnyObserver<Void>
    }
    
    struct Output {
        let image: Observable<String>
        let isFavoriteHidden: Observable<Bool>
        let isFavorite: Observable<Bool>
        let discount: Observable<String>
        let isDiscountHidden: Observable<Bool>
        let price: Observable<String>
        let name: Observable<String>
        let isNewHidden: Observable<Bool>
        let cellCount: Observable<String>
        let isCellCountHidden: Observable<Bool>
        let favoriteTapped: Observable<Goods>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let favoriteTapSubject = PublishSubject<Void>()
    private let imageRelay = PublishRelay<String>()
    private let isFavoriteHidden = PublishRelay<Bool>()
    private let isFavoriteRelay = PublishRelay<Bool>()
    private let discountRelay = PublishRelay<String>()
    private let isDiscountHiddenRelay = PublishRelay<Bool>()
    private let priceRelay = PublishRelay<String>()
    private let nameRelay = PublishRelay<String>()
    private let isNewHiddenRelay = PublishRelay<Bool>()
    private let cellCountRelay = PublishRelay<String>()
    private let isCellCountHiddenRelay = PublishRelay<Bool>()
    private let favoriteTappedRelay = PublishRelay<Goods>()
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
        input = Input(
            loadData: loadDataSubject.asObserver(),
            favoriteTap: favoriteTapSubject.asObserver()
        )
        output = Output(
            image: imageRelay.asObservable(),
            isFavoriteHidden: isFavoriteHidden.asObservable(),
            isFavorite: isFavoriteRelay.asObservable(),
            discount: discountRelay.asObservable(),
            isDiscountHidden: isDiscountHiddenRelay.asObservable(),
            price: priceRelay.asObservable(),
            name: nameRelay.asObservable(),
            isNewHidden: isNewHiddenRelay.asObservable(),
            cellCount: cellCountRelay.asObservable(),
            isCellCountHidden: isCellCountHiddenRelay.asObservable(),
            favoriteTapped: favoriteTappedRelay.asObservable()
        )

        transform()
    }

    func transform() {
        let goodsRelay = PublishRelay<Goods>()

        loadDataSubject
            .withUnretained(self)
            .map { owner, _ in
                owner.dependency.goods
            }
            .bind(to: goodsRelay)
            .disposed(by: disposeBag)

        favoriteTapSubject
            .withUnretained(self)
            .map { owner, _ in owner.dependency.goods }
            .bind(to: favoriteTappedRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.image }
            .bind(to: imageRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .withUnretained(self)
            .map { owner, _ in !owner.dependency.isFavoriteEnabled }
            .bind(to: isFavoriteHidden)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.isFavorite }
            .bind(to: isFavoriteRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { "\($0.discount)%" }
            .bind(to: discountRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.discount == 0 }
            .bind(to: isDiscountHiddenRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .withUnretained(self)
            .map { owner, goods in owner.convertIntToFomattedString(value: goods.price) }
            .bind(to: priceRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.name }
            .bind(to: nameRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { !$0.isNew }
            .bind(to: isNewHiddenRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .withUnretained(self)
            .map { owner, goods in owner.convertIntToFomattedString(value: goods.sellCount) + "??? ?????????" }
            .bind(to: cellCountRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.sellCount < 10 }
            .bind(to: isCellCountHiddenRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.isFavorite }
            .bind(to: isFavoriteRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension GoodsCellViewModel {

    private func convertIntToFomattedString(value: Int) -> String {
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
