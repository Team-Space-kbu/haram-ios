//
//  CheckIDCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/10/24.
//

import UIKit

final class CheckIDCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let userMail: String
  
  init(userMail: String, navigationController: UINavigationController) {
    self.userMail = userMail
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CheckIDViewController = CheckIDViewController(
      viewModel: CheckIDViewModel(
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

extension CheckIDCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(on: self.navigationController, message: .custom(message), confirmHandler: confirmHandler)
  }
  
  func showFindIDResultViewController(authCode: String) {
    let coordinator = FindIDResultCoordinator(
      userMail: userMail,
      authCode: authCode,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
