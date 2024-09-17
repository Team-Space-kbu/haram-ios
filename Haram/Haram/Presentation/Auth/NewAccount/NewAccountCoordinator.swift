//
//  NewAccountCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import UIKit

final class NewAccountCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: NewAccountViewController = NewAccountViewController(
      viewModel: NewAccountViewModel(
        dependency: .init(
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension NewAccountCoordinator {
  func showVerifyEmailViewController() {
    let coordinator = VerifyEmailCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(title: title, message: message, viewController: self.navigationController, confirmHandler: confirmHandler)
  }
}
