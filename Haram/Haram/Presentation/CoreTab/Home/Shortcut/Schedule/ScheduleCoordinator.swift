//
//  ScheduleCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class ScheduleCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: ScheduleViewController = ScheduleViewController(
      viewModel: ScheduleViewModel(
        dependency: .init(
          intranetRepository: IntranetRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension ScheduleCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}


