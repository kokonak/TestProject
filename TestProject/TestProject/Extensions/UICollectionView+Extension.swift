//
//  UICollectionView+Extension.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import UIKit

extension UICollectionView {

    func register<T: UICollectionReusableView>(_ viewClass: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deqeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        forIndexPath indexPath: IndexPath,
        kind: String
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not deqeue reusable supplymentary view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}
