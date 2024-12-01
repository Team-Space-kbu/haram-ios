//
//  LibraryCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/18/24.
//

import UIKit

final class LibraryCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LibraryViewController = LibraryViewController(
      viewModel: LibraryViewModel(
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

extension LibraryCoordinator {
  func showLibraryDetailViewController(path: Int) {
    print("도서관 상세화면 이동 \(path)")
    let vc = LibraryDetailViewController(path: path)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController.pushViewController(vc, animated: true)
  }
  
  func showLibraryResultViewController(searchQuery: String) {
    print("도서관 검색 결과화면 이동")
    let vc = LibraryResultsViewController(searchQuery: searchQuery)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController.pushViewController(vc, animated: true)
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
