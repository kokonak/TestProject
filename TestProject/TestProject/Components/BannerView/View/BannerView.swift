//
//  BannerView.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//

import UIKit
import RxSwift
import SDWebImage

final class BannerView: UIView {

    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
        $0.scrollDirection = .horizontal
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .clear
        $0.register(BannerViewCell.self)
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = false
    }

    private let bannerCountContainerView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private let bannerCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
    }

    private let viewModel: BannerViewModel
    private let disposeBag = DisposeBag()
    private var timer: Timer?

    init(_ viewModel: BannerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bindViewModel()
        bindUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = collectionView.frame.size
    }
}

// MARK: - Initialize UI
extension BannerView {

    /// Setup UI
    private func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addSubview(bannerCountContainerView)
        bannerCountContainerView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
        bannerCountContainerView.addSubview(bannerCountLabel)
        bannerCountLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
}


// MARK: - Binding ViewModel
extension BannerView {

    /// Binding ViewModel
    private func bindViewModel() {
        bindViewModelInput()
        bindViewModelOutput()
    }

    /// Binding input of ViewModel
    private func bindViewModelInput() {
        collectionView.rx.didScroll
            .withUnretained(self)
            .map { owner, _ in
                Int(owner.collectionView.contentOffset.x / (owner.flowLayout.itemSize.width / 2) + 1) / 2
            }
            .bind(to: viewModel.input.currentBannerIndex)
            .disposed(by: disposeBag)
    }

    /// Binding output of ViewModel
    private func bindViewModelOutput() {
        viewModel.output.banners
            .bind(to: collectionView.rx.items(
                cellIdentifier: BannerViewCell.reuseIdentifier,
                cellType: BannerViewCell.self
            )) { index, banner, cell in
                cell.setData(banner)
            }
            .disposed(by: disposeBag)

        viewModel.output.banners
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] banners in
                self?.handleBannerSize(banners: banners)
            })
            .disposed(by: disposeBag)

        viewModel.output.bannerCountText
            .bind(to: bannerCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.isBannerCountHidden
            .bind(to: bannerCountContainerView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    /// Binding rx associated UI
    private func bindUI() {
        Observable.merge([
            collectionView.rx.didScroll.map { () },
            collectionView.rx.didEndDecelerating.map { () }
        ])
        .observe(on: MainScheduler.asyncInstance)
        .withLatestFrom(viewModel.output.banners)
        .withUnretained(self)
        .map { owner, banners in owner.handleContentOffset(banners.count) }
        .filterNil()
        .distinctUntilChanged()
        .bind(to: collectionView.rx.contentOffset)
        .disposed(by: disposeBag)

        // auto scroll
        collectionView.rx.didScroll
            .withLatestFrom(viewModel.output.banners)
            .asDriver(onErrorJustReturn: [])
            .filter { $0.count > 1 }
            .drive(onNext: { [weak self] banners in
                self?.handleAutoScroll(bannerCount: banners.count)
            })
            .disposed(by: disposeBag)

    }
}

// MARK: - Other Methods
extension BannerView {

    /// Banner의 이미지 크기에 따른 비율로 itemSize 설정.
    private func handleBannerSize(banners: [Banner]) {
        guard let banner = banners.first else { return }

        SDWebImageDownloader.shared.downloadImage(with: URL(string: banner.image)) { [weak self] image, _, _, _ in
            guard let self = self else { return }
            guard let image = image else { return }

            self.collectionView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(
                    round(image.size.height / image.size.width * self.collectionView.frame.width)
                ).priority(.high)
            }

            UIView.setAnimationsEnabled(false)
            self.superview?.invalidateIntrinsicContentSize()
            UIView.setAnimationsEnabled(true)

            // 배너가 1개 초과시 실제 첫번째 아이템의 인덱스는 1이므로 해당 위치로 스크롤 해줌
            guard banners.count > 1 else { return }
            DispatchQueue.main.async {
                self.collectionView.setContentOffset(CGPoint(x: self.flowLayout.itemSize.width, y: 0), animated: false)
            }
        }
    }

    private func handleContentOffset(_ bannerCount: Int) -> CGPoint? {
        guard bannerCount > 1 else { return nil }

        let contentOffsetX = collectionView.contentOffset.x
        let width = flowLayout.itemSize.width
        let index = Int(contentOffsetX / collectionView.frame.width)
        let offset: CGPoint?
        switch index {
            case 0:
                offset = CGPoint(x: width * CGFloat(bannerCount - 2) + contentOffsetX, y: 0)
            case bannerCount - 1:
                offset = CGPoint(x: contentOffsetX - width * CGFloat(bannerCount - 2), y: 0)
            default:
                offset = nil
        }
        return offset
    }

    private func handleAutoScroll(bannerCount: Int) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }

            let contentOffsetX = self.collectionView.contentOffset.x
            let width = self.flowLayout.itemSize.width
            let nextIndex = Int(contentOffsetX / self.collectionView.frame.width) + 1

            if bannerCount > nextIndex {
                self.collectionView.scrollToItem(at: [0, nextIndex], at: .centeredHorizontally, animated: true)
            } else {
                self.collectionView.scrollToItem(at: [0, 1], at: .centeredHorizontally, animated: false)
                self.collectionView.scrollToItem(at: [0, 2], at: .centeredHorizontally, animated: true)
            }
        })
    }
}
