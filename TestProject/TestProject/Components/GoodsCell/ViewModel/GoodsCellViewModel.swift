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
    }
    
    struct Output {
        let image: Observable<String>
        let discount: Observable<String>
        let isDiscountHidden: Observable<Bool>
        let price: Observable<String>
        let name: Observable<String>
        let isNewHidden: Observable<Bool>
        let cellCount: Observable<String>
        let isCellCountHidden: Observable<Bool>
    }

    let dependency: Dependency
    let input: Input
    let output: Output
    let disposeBag = DisposeBag()
    private let loadDataSubject = PublishSubject<Void>()
    private let imageRelay = PublishRelay<String>()
    private let discountRelay = PublishRelay<String>()
    private let isDiscountHiddenRelay = PublishRelay<Bool>()
    private let priceRelay = PublishRelay<String>()
    private let nameRelay = PublishRelay<String>()
    private let isNewHiddenRelay = PublishRelay<Bool>()
    private let cellCountRelay = PublishRelay<String>()
    private let isCellCountHiddenRelay = PublishRelay<Bool>()
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
        input = Input(loadData: loadDataSubject.asObserver())
        output = Output(
            image: imageRelay.asObservable(),
            discount: discountRelay.asObservable(),
            isDiscountHidden: isDiscountHiddenRelay.asObservable(),
            price: priceRelay.asObservable(),
            name: nameRelay.asObservable(),
            isNewHidden: isNewHiddenRelay.asObservable(),
            cellCount: cellCountRelay.asObservable(),
            isCellCountHidden: isCellCountHiddenRelay.asObservable()
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

        goodsRelay
            .map { $0.image }
            .bind(to: imageRelay)
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
            .map { owner, goods in owner.convertIntToFomattedString(value: goods.cellCount) + "개 구매중" }
            .bind(to: cellCountRelay)
            .disposed(by: disposeBag)

        goodsRelay
            .map { $0.cellCount < 10 }
            .bind(to: isCellCountHiddenRelay)
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
