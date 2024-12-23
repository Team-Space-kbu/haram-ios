//
//  MoreCategoryCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/24/24.
//

import UIKit

final class MoreCategoryCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let noticeType: NoticeType
  private let title: String
  
  init(title: String, noticeType: NoticeType, navigationController: UINavigationController) {
    self.title = title
    self.noticeType = noticeType
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: MoreCategoryViewController = MoreCategoryViewController(
      viewModel: MoreCategoryViewModel(
        dependency: .init(
          noticeRepository: NoticeRepositoryImpl(),
          coordinator: self
        ),
        payload: .init(noticeType: noticeType)
      )
    )
    viewController.title = title
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension MoreCategoryCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showNoticeDetailViewController(path: String) {
    let coordinator = NoticeDetailCoordinator(path: path, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}

