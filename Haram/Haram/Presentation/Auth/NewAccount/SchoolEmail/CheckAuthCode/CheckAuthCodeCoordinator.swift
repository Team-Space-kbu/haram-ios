//
//  CheckAuthCodeCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import UIKit

final class CheckAuthCodeCoordinator: Coordinator {
  private let userMail: String
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(userMail: String, navigationController: UINavigationController) {
    self.userMail = userMail
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CheckAuthCodeViewController = CheckAuthCodeViewController(
      viewModel: CheckAuthCodeViewModel(
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

extension CheckAuthCodeCoordinator {
  func showRegisterViewController(authCode: String) {
    let coordinator = RegisterCoordinator(
      authCode: authCode,
      email: userMail,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}

