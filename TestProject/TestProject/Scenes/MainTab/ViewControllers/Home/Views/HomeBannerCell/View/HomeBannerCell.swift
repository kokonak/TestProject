//
//  HomeBannerView.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import UIKit
import RxSwift

final class HomeBannerCell: UICollectionViewCell {

    private let bannerViewModel = BannerViewModel()
    private lazy var bannerView = BannerView(bannerViewModel)
    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - Initialize UI
extension HomeBannerCell {

    /// Setup UI
    private func setupUI() {
        clipsToBounds = true

        contentView.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Other Methods
extension HomeBannerCell {

    func setData(_ viewModel: HomeBannerCellViewModel) {
        viewModel.output.banners
            .bind(to: bannerViewModel.input.banners)
            .disposed(by: disposeBag)

        viewModel.input.loadData.onNext(())
    }
}
