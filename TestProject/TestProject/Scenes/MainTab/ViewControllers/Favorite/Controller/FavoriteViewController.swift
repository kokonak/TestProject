//
//  FavoriteViewController.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//  
//

import UIKit

import RxSwift
import RxCocoa

final class FavoriteViewController: UIViewController {

    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout).then {
        $0.register(GoodsCell.self)
        $0.alwaysBounceVertical = true
    }

    // MARK: - Properties
    private let viewModel: FavoriteViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: FavoriteViewModel = FavoriteViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        bindUI()

        viewModel.input.loadData.onNext(())
    }
}

// MARK: - Initialize UI
extension FavoriteViewController {
    /// Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Binding ViewModel
extension FavoriteViewController {

    /// Binding ViewModel
    private func bindViewModel() {
        bindViewModelInput()
        bindViewModelOutput()
    }

    /// Binding input of ViewModel
    private func bindViewModelInput() {

    }

    /// Binding output of ViewModel
    private func bindViewModelOutput() {
        viewModel.output.goods
            .bind(to: collectionView.rx.items(
                cellIdentifier: GoodsCell.reuseIdentifier,
                cellType: GoodsCell.self
            )) { index, goods, cell in
                cell.setData(goods)
            }
            .disposed(by: disposeBag)
    }

    /// Binding rx associated UI
    private func bindUI() {

    }
}

// MARK: - Other Functions
extension FavoriteViewController {

}
