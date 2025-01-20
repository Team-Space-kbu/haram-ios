//
//  SearchBookCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/3/24.
//

import UIKit

final class SearchBookCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let searchQuery: String
  
  init(searchQuery: String, navigationController: UINavigationController) {
    self.searchQuery = searchQuery
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: SearchBookViewController = SearchBookViewController(
      viewModel: SearchBookViewModel(
        payload: .init(searchQuery: searchQuery),
        dependency: .init(
          libraryRepository: LibraryRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension SearchBookCoordinator {
  func showLibraryDetailViewController(path: Int) {
    let coordinator = BookDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
