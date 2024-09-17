//
//  NoticeListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class NoticeListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: NoticeListViewController = NoticeListViewController(
      viewModel: NoticeListViewModel(
        dependency: .init(
          noticeRepository: NoticeRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension NoticeListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showNoticeDetailViewController(path: String) {
    let coordinator = NoticeDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showSelectedCategoryViewController(noticeType: NoticeType) {
    let coordinator = SelectedCategoryCoordinator(
      noticeType: noticeType,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
