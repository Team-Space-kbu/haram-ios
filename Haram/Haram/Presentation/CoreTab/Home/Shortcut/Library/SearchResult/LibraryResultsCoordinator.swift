//
//  LibraryResultsCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/3/24.
//

import UIKit

final class LibraryResultsCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let searchQuery: String
  
  init(searchQuery: String, navigationController: UINavigationController) {
    self.searchQuery = searchQuery
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LibraryResultsViewController = LibraryResultsViewController(
      viewModel: LibraryResultsViewModel(
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

extension LibraryResultsCoordinator {
  func showLibraryDetailViewController(path: Int) {
    let coordinator = LibraryDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(title: title, message: message, viewController: self.navigationController, confirmHandler: confirmHandler)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
