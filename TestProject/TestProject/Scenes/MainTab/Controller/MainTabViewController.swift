//
//  MainTabViewController.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//  
//

import UIKit
import RxSwift
import RxOptional
import Then

final class MainTabViewController: UITabBarController {

    // MARK: - Properties
    private let viewModel: MainTabViewModel
    private let disposeBag = DisposeBag()

    init(_ viewModel: MainTabViewModel = MainTabViewModel()) {
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
extension MainTabViewController {

    /// Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        tabBar.tintColor = R.color.light_carmine_pink()
        tabBar.isTranslucent = false
    }
}

// MARK: - Binding ViewModel
extension MainTabViewController {

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
        viewModel.output.tabs
            .withUnretained(self)
            .map { owner, tabs in tabs.map { owner.getViewController(with: $0) }}
            .bind(to: rx.viewControllers)
            .disposed(by: disposeBag)

        viewModel.output.tabs
            .map { $0.first?.title }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
    }

    /// Binding rx associated UI
    private func bindUI() {
        rx.didSelect
            .withUnretained(self)
            .map { owner, controller in owner.viewControllers?.firstIndex(of: controller) }
            .filterNil()
            .withLatestFrom(viewModel.output.tabs) { ($0, $1) }
            .map { index, tabs in tabs[index].title }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
    }
}

// MARK: - Other Methods
extension MainTabViewController {

    private func getViewController(with tab: TabModel) -> UIViewController {
        let controller: UIViewController
        switch tab {
            case .home:     controller = HomeViewController()
            case .favorite: controller = FavoriteViewController()
        }
        return controller.then {
            $0.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.normalImage,
                selectedImage: tab.selectedImage
            )
        }
    }
}
