//
//  GoodsRealmObject.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import Foundation
import RealmSwift

final class GoodsRealmObject: Object {

    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var image: String
    @Persisted var actualPrice: Int
    @Persisted var price: Int
    @Persisted var isNew: Bool
    @Persisted var cellCount: Int
    @Persisted var createdAt: Date

    convenience init(goods: Goods) {
        self.init()
        id = goods.id
        name = goods.name
        image = goods.image
        actualPrice = goods.actualPrice
        price = goods.price
        isNew = goods.isNew
        cellCount = goods.sellCount
        createdAt = Date()
    }

    func asGoods() -> Goods {
        Goods(
            id: id,
            name: name,
            image: image,
            actualPrice: actualPrice,
            price: price,
            isNew: isNew,
            sellCount: cellCount
        )
    }
}
