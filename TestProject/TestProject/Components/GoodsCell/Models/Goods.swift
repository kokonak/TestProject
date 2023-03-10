//
//  Goods.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import Then

struct Goods: Codable, Equatable {

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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case actualPrice = "actual_price"
        case price
        case isNew = "is_new"
        case sellCount = "sell_count"
    }
}

extension Goods: Then { }
