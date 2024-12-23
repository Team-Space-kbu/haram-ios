//
//  RegisterCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/5/24.
//

import UIKit

final class RegisterCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let authCode: String
  private let email: String
  
  init(authCode: String, email: String, navigationController: UINavigationController) {
    self.authCode = authCode
    self.email = email
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: RegisterViewController = RegisterViewController(
      viewModel: RegisterViewModel(
        payload: .init(
          authCode: authCode,
          email: email
        ),
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension RegisterCoordinator {
  func popToRootViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToRootViewController(animated: true)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(on: self.navigationController, message: .custom(message), confirmHandler: confirmHandler)
  }
}
