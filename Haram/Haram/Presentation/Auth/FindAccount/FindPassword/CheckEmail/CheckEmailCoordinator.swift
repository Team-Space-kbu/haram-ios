//
//  CheckEmailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import UIKit

final class CheckEmailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let userMail: String
  
  init(userMail: String, navigationController: UINavigationController) {
    self.userMail = userMail
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CheckEmailViewController = CheckEmailViewController(
      viewModel: CheckEmailViewModel(
        payload: .init(userMail: userMail),
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension CheckEmailCoordinator {
  func showUpdatePasswordViewController(authCode: String) {
    let coordinator = UpdatePasswordCoordinator(
      authCode: authCode,
      userMail: userMail,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(title: title, message: message, viewController: self.navigationController, confirmHandler: confirmHandler)
  }
}
