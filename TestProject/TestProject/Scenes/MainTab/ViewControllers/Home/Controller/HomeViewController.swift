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
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout).then {
        $0.register(
            HomeBannerCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeBannerCell.reuseIdentifier
        )
        $0.register(GoodsCell.self)
        $0.alwaysBounceVertical = true
        $0.refreshControl = refreshControl
    }

    private let refreshControl = UIRefreshControl()

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
        refreshControl.rx.controlEvent(.valueChanged)
            .map { () }
            .bind(to: viewModel.input.loadData)
            .disposed(by: disposeBag)

        collectionView.rx.willDisplayCell
            .map { $0.at }
            .withLatestFrom(viewModel.output.sectionModels) { ($0, $1) }
            .filter { index, sectionModels in
                guard let section = sectionModels.first else { return false }
                return index.row == section.items.count - 1
            }
            .map { _, _ in () }
            .bind(to: viewModel.input.loadMore)
            .disposed(by: disposeBag)
    }

    /// Binding output of ViewModel
    private func bindViewModelOutput() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<HomeSectionModel>(
            configureCell: { _, collectionView, index, viewModel in
                let cell: GoodsCell = collectionView.dequeueReusableCell(forIndexPath: index)
                cell.setData(viewModel)
                return cell
            },
            configureSupplementaryView: { dataSource, collectionView, identifer, index in
                guard let viewModel = dataSource.sectionModels.first?.bannerViewModel else {
                    return HomeBannerCell()
                }

                let view: HomeBannerCell = collectionView.dequeueReusableSupplementaryView(
                    forIndexPath: index,
                    kind: UICollectionView.elementKindSectionHeader
                )
                view.setData(viewModel)
                return view
            })

        viewModel.output.sectionModels
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.output.stopRefreshing
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }

    /// Binding rx associated UI
    private func bindUI() {

    }
}

// MARK: - Other Functions
extension HomeViewController: UICollectionViewDelegateFlowLayout {

}
