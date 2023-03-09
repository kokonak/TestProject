//
//  Goods.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

struct Goods {
    let id: Int
    let name: String
    let image: String
    let actualPrice: Int // 기본 가격
    let price: Int // 할인된 가격
    let isNew: Bool
    let cellCount: Int
    var discount: Int {
        Int((1 - Float(price) / Float(actualPrice)) * 100)
    }
}

extension Goods {

    static var dummies: [Goods] = [
        .init(
            id: 0,
            name: "[세트할인!]인기상품~벨치스 포켓 후드집업",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 9000,
            isNew: true,
            cellCount: 1234
        ),
        .init(
            id: 1,
            name: "[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품 dfgdfgfdgfdgdfgdfgdfgfdgfdg",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 10000,
            isNew: true,
            cellCount: 1234
        ),
        .init(
            id: 2,
            name: "[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 9000,
            isNew: false,
            cellCount: 1234
        ),
        .init(
            id: 3,
            name: "[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품 dfgdfgfdgfdgdfgdfgdfgfdgfdg",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 9000,
            isNew: true,
            cellCount: 9
        ),
        .init(
            id: 4,
            name: "[세트할인!]인기상품~벨치스 포켓 후드집업 + 피얼즈 골지스판 뷔스티에 원피스 세트상품 dfgdfgfdgfdgdfgdfgdfgfdgfdg",
            image: "https://d20s70j9gw443i.cloudfront.net/t_GOODS_THUMB_WEBP/https://imgb.a-bly.com/data/goods/20210122_1611290798811044s.jpg",
            actualPrice: 10000,
            price: 10000,
            isNew: false,
            cellCount: 9
        )
    ]
}
