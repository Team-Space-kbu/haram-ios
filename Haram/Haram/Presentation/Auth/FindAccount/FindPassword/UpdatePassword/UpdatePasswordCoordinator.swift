//
//  UpdatePasswordCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/12/24.
//

import UIKit

final class UpdatePasswordCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let authCode: String
  private let userMail: String
  
  init(authCode: String, userMail: String, navigationController: UINavigationController) {
    self.authCode = authCode
    self.userMail = userMail
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: UpdatePasswordViewController = UpdatePasswordViewController(
      viewModel: UpdatePasswordViewModel(
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        ), 
        payload: .init(
          authCode: authCode,
          userMail: userMail
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension UpdatePasswordCoordinator {
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

