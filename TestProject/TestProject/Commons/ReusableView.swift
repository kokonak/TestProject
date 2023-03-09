//
//  ReusableView.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import UIKit

extension UICollectionReusableView {

    static var reuseIdentifier: String {
        String(describing: self)
    }
}

enum CollectionSupplementaryViewType {
    case header
    case footer
    case custom(kind: String)

    var identifier: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        case let .custom(kind):
            return kind
        }
    }
}

extension UICollectionView {

    func register<T: UICollectionReusableView>(_ viewClass: T.Type, kind: CollectionSupplementaryViewType? = nil) {
        if let kind = kind {
            register(
                T.self,
                forSupplementaryViewOfKind: kind.identifier,
                withReuseIdentifier: T.reuseIdentifier
            )
        } else {
            register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deqeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        kind: CollectionSupplementaryViewType,
        forIndexPath indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind.identifier,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not deqeue cell with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}
