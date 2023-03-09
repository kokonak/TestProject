//
//  HomeSectionModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import RxDataSources

struct HomeSectionModel {
    
    var items: [HomeItem]

    func getGoodsCellViewModelIndex(_ viewModel: GoodsCellViewModel) -> Int? {
        items.firstIndex(where: { item in
            if case .goods(let cellViewModel) = item,
               viewModel.dependency.goods.id == cellViewModel.dependency.goods.id {
                return true
            }
            return false
        })
    }
}

extension HomeSectionModel: SectionModelType {

    init(original: HomeSectionModel, items: [HomeItem]) {
        self = original
        self.items = items
    }
}
