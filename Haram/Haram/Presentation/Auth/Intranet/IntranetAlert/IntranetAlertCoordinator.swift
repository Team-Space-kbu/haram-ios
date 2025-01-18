//
//  IntranetAlertCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/21/24.
//

import UIKit

final class IntranetAlertCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: IntranetAlertViewController = IntranetAlertViewController(
      viewModel: IntranetAlertViewModel(
        dependency: .init(coordinator: self)
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    let startIdx = self.navigationController.viewControllers.startIndex
    self.navigationController.viewControllers.remove(at: startIdx + 1)
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension IntranetAlertCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func popToRootViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToRootViewController(animated: true)
  }
  
  func showIntranetLoginViewController() {
    let coordinator = IntranetLoginCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
