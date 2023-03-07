//
//  TabModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//

import Foundation
import UIKit

enum TabModel: CaseIterable {

    case home
    case favorite

    var title: String {
        switch self {
            case .home:     return "홈"
            case .favorite: return "좋아요"
        }
    }

    var normalImage: UIImage? {
        switch self {
            case .home:     return R.image.icon_house()
            case .favorite: return R.image.icon_heart()
        }
    }

    var selectedImage: UIImage? {
        switch self {
            case .home:     return R.image.icon_house_fill()
            case .favorite: return R.image.icon_heart_fill()
        }
    }
}
