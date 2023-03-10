//
//  BannerViewCell.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import UIKit
import SnapKit
import SDWebImage

final class BannerViewCell: UICollectionViewCell {

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Initialize UI
extension BannerViewCell {

    /// Setup UI
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Other Methods
extension BannerViewCell {

    func setData(_ banner: Banner) {
        imageView.sd_setImage(with: URL(string: banner.image))
    }
}
