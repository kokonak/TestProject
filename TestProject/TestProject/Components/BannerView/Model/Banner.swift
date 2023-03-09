//
//  Banner.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

struct Banner {

    let id: Int
    let image: String
}

extension Banner {

    static var dummies: [Banner] = [
        Banner(id: 0, image: "https://img.a-bly.com/banner/images/banner_image_1615465448476691.jpg"),
        Banner(id: 1, image: "https://img.a-bly.com/banner/images/banner_image_1615970086333899.jpg"),
        Banner(id: 2, image: "https://img.a-bly.com/banner/images/banner_image_1615962899391279.jpg")
    ]
}
