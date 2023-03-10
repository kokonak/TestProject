//
//  UICollectionReusableView+Extension.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import UIKit

extension UICollectionReusableView {

    static var reuseIdentifier: String {
        String(describing: self)
    }
}
