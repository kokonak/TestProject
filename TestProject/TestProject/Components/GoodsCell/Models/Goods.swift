//
//  Goods.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import Then

struct Goods {
    let id: Int
    let name: String
    let image: String
    let actualPrice: Int // 기본 가격
    let price: Int // 할인된 가격
    let isNew: Bool
    let sellCount: Int
    var discount: Int {
        Int((1 - Float(price) / Float(actualPrice)) * 100)
    }
    var isFavorite: Bool = false
}

extension Goods: Then { }

extension Goods {

    static var dummies: [Goods] = (0..<20).map {
        .init(
            id: $0,
            name: "[세트할인!] Goods \($0)",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 9000,
            isNew: true,
            cellCount: 9
        )
    }
}
