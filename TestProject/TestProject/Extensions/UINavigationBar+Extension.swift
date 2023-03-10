//
//  UINavigationBar+Extension.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//

import UIKit

extension UINavigationBar {

    class func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
