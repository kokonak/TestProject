//
//  HomeViewController.swift
//  TestProject
//
//  Created by kokonak on 2023/03/08.
//  
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class HomeViewController: UIViewController {

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
        $0.register(HomeBannerCell.self)
        $0.register(GoodsCell.self)
        $0.alwaysBounceVertical = true
    }

    // MARK: - Properties
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()

    init(_ viewModel: HomeViewModel = HomeViewModel()) {
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
extension HomeViewController {
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
extension HomeViewController {

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
        let dataSource = RxCollectionViewSectionedReloadDataSource<HomeSectionModel> { _, collectionView, index, item in
            switch item {
                case .banner(let viewModel):
                    let cell: HomeBannerCell = collectionView.dequeueReusableCell(forIndexPath: index)
                    cell.setData(viewModel)
                    return cell

                case .goods(let viewModel):
                    let cell: GoodsCell = collectionView.dequeueReusableCell(forIndexPath: index)
                    cell.setData(viewModel)
                    return cell
            }
        }

        viewModel.output.sectionModels
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    /// Binding rx associated UI
    private func bindUI() {

    }
}

// MARK: - Other Functions
extension HomeViewController: UICollectionViewDelegateFlowLayout {

}
