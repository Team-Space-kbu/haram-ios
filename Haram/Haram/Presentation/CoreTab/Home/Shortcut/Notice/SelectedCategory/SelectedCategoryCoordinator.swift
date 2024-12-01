//
//  SelectedCategoryCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/22/24.
//

import UIKit

final class SelectedCategoryCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let noticeType: NoticeType
  
  init(noticeType: NoticeType, navigationController: UINavigationController) {
    self.noticeType = noticeType
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: SelectedCategoryNoticeViewController = SelectedCategoryNoticeViewController(
      viewModel: SelectedCategoryNoticeViewModel(
        dependency: .init(
          noticeRepository: NoticeRepositoryImpl(),
          coordinator: self
        ),
        payload: .init(noticeType: noticeType)
      )
    )
    viewController.title = "공지사항"
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension SelectedCategoryCoordinator {
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
