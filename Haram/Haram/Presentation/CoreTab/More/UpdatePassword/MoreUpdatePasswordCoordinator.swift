//
//  UpdatePasswordCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/12/24.
//

import UIKit

final class MoreUpdatePasswordCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: MoreUpdatePasswordViewController = MoreUpdatePasswordViewController(
      viewModel: MoreUpdatePasswordViewModel(
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension MoreUpdatePasswordCoordinator {
  func showVerifyEmailViewController() {
    let coordinator = VerifyEmailCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func popToRootViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToRootViewController(animated: true)
  }
}
