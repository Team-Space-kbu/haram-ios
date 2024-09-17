//
//  FindPasswordCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import UIKit

final class FindPasswordCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: FindPasswordViewController = FindPasswordViewController(
      viewModel: FindPasswordViewModel(
        payload: .init(),
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension FindPasswordCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showCheckEmailViewController(userMail: String) {
    let coordinator = CheckEmailCoordinator(userMail: userMail, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
