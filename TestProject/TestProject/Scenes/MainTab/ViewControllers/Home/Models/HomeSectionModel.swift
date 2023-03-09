//
//  HomeSectionModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import RxDataSources

struct HomeSectionModel {
    var items: [HomeItem]
}

extension HomeSectionModel: SectionModelType {

    typealias Item = HomeItem

    init(original: HomeSectionModel, items: [HomeItem]) {
        self = original
        self.items = items
    }
}
