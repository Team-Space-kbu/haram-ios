//
//  NoticeDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/22/24.
//

import UIKit

final class NoticeDetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let path: String
  
  init(path: String, navigationController: UINavigationController) {
    self.path = path
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: NoticeDetailViewController = NoticeDetailViewController(
      viewModel: NoticeDetailViewModel(
        dependency: .init(
          noticeRepository: NoticeRepositoryImpl(),
          coordinator: self
        ),
        payload: .init(
          type: .student,
          path: path
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension NoticeDetailCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
