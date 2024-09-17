//
//  FindAccountCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import UIKit

final class FindAccountCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: FindAccountViewController = FindAccountViewController(
      viewModel: FindAccountViewModel(
        dependency: .init(coordinator: self)
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension FindAccountCoordinator {
  func showFindIDViewController() {
    let coordinator = FindIDCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showFindPasswordViewController() {
    let coordinator = FindPasswordCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
