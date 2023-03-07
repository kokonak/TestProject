//
//  UITabBar+Extension.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//

import UIKit

extension UITabBar {

    class func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .systemBackground
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
