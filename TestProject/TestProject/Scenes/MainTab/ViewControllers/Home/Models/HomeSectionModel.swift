//
//  HomeSectionModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import RxDataSources

struct HomeSectionModel {

    let bannerViewModel: HomeBannerCellViewModel
    var items: [GoodsCellViewModel]

    var lastGoodsId: Int? {
        items.last?.dependency.goods.id
    }
}

extension HomeSectionModel: SectionModelType {

    typealias Item = GoodsCellViewModel

    init(original: HomeSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
