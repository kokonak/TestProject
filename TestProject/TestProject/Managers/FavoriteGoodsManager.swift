//
//  FavoriteGoodsManager.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import Foundation
import RxSwift
import RxRelay

final class FavoriteGoodsManager {

    static let shared = FavoriteGoodsManager()

    private(set) lazy var favoriteGoodsList: Observable<[Goods]> = goodsListRelay.asObservable()
    private lazy var goodsListRelay = BehaviorRelay<[Goods]>(value: [])

    func addGoods(_ goods: Goods) {
        var goodsList = goodsListRelay.value
        goodsList.insert(goods, at: 0)
        goodsListRelay.accept(goodsList)
    }

    func removeGoods(_ goods: Goods) {
        var goodsList = goodsListRelay.value
        goodsList.removeAll(where: { $0.id == goods.id })
        goodsListRelay.accept(goodsList)
    }
}
