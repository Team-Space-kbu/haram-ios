//
//  BookDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/2/24.
//

import UIKit

final class BookDetailCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let path: Int
  
  init(path: Int, navigationController: UINavigationController) {
    self.path = path
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BookDetailViewController = BookDetailViewController(
      viewModel: BookDetailViewModel(
        payload: .init(path: path),
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

extension BookDetailCoordinator {
  func showLibraryDetailViewController(path: Int) {
    let coordinator = BookDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showZoomImageViewController(imageURL: URL) {
    let modal = ZoomImageViewController(zoomImageURL: imageURL)
    modal.modalPresentationStyle = .fullScreen
    navigationController.present(modal, animated: true)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}

