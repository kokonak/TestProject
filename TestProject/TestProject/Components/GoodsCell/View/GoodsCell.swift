//
//  GoodsCell.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//

import UIKit
import RxSwift

final class GoodsCell: UICollectionViewCell {

    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }

    private let favoriteButton = UIButton().then {
        $0.setImage(R.image.icon_heart(), for: .normal)
        $0.setImage(R.image.icon_heart_fill()?.withTintColor(R.color.light_carmine_pink()!), for: .selected)
    }

    private let discountLabel = UILabel().then {
        $0.textColor = R.color.light_carmine_pink()
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let priceLabel = UILabel().then {
        $0.textColor = R.color.text_primary()
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private let nameLabel = UILabel().then {
        $0.textColor = R.color.text_secondary()
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 0
    }

    private let newLabel = UILabel().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = R.color.text_secondary()?.cgColor
        $0.layer.cornerRadius = 2
        $0.textColor = R.color.text_primary()
        $0.font = .systemFont(ofSize: 10)
        $0.text = "NEW"
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let cellCountLabel = UILabel().then {
        $0.textColor = R.color.text_secondary()
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

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
extension GoodsCell {

    /// Setup UI
    private func setupUI() {
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }

        containerView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        containerView.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints {
            $0.top.trailing.equalTo(imageView)
            $0.width.height.equalTo(40)
        }

        let stackView = UIStackView().then {
            $0.axis = .vertical
        }
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(18)
            $0.top.trailing.bottom.equalToSuperview()
        }

        let priceStackView = UIStackView().then {
            $0.spacing = 5
        }
        stackView.addArrangedSubview(priceStackView)
        priceStackView.addArrangedSubview(discountLabel)
        priceStackView.addArrangedSubview(priceLabel)
        stackView.setCustomSpacing(8, after: priceStackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.setCustomSpacing(18, after: nameLabel)

        let bottomContainerView = UIView()
        stackView.addArrangedSubview(bottomContainerView)
        let bottomStackView = UIStackView().then {
            $0.spacing = 5
        }
        bottomContainerView.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        bottomStackView.addArrangedSubview(newLabel)
        newLabel.snp.makeConstraints {
            $0.width.equalTo(34)
            $0.height.equalTo(18)
        }
        bottomStackView.addArrangedSubview(cellCountLabel)

        let separator = UIView().then {
            $0.backgroundColor = .gray.withAlphaComponent(0.2)
        }
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

// MARK: - Other Methods
extension GoodsCell {

    func setData(_ viewModel: GoodsCellViewModel) {
        favoriteButton.rx.tap
            .bind(to: viewModel.input.favoriteTap)
            .disposed(by: disposeBag)

        viewModel.output.image
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] image in
                self?.imageView.sd_setImage(with: URL(string: image))
            })
            .disposed(by: disposeBag)

        viewModel.output.isFavoriteHidden
            .bind(to: favoriteButton.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.output.isFavorite
            .bind(to: favoriteButton.rx.isSelected)
            .disposed(by: disposeBag)

        viewModel.output.discount
            .bind(to: discountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.isDiscountHidden
            .bind(to: discountLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.output.price
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.name
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.isNewHidden
            .bind(to: newLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.output.cellCount
            .bind(to: cellCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.isCellCountHidden
            .bind(to: cellCountLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.input.loadData.onNext(())
    }
}
