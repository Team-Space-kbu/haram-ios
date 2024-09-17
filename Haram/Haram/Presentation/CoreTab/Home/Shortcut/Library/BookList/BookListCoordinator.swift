//
//  BookListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/18/24.
//

import UIKit

final class BookListCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BookListViewController = BookListViewController(
      viewModel: BookListViewModel(
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

extension BookListCoordinator {
  func showLibraryDetailViewController(path: Int) {
    let coordinator = BookDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showLibraryResultViewController(searchQuery: String) {
    let coordinator = SearchBookCoordinator(searchQuery: searchQuery, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showZoomImageViewController(imageURL: URL) {
    let modal = ZoomImageViewController(zoomImageURL: imageURL)
    modal.modalPresentationStyle = .fullScreen
    navigationController.present(modal, animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(title: title, message: message, viewController: self.navigationController, confirmHandler: confirmHandler)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
