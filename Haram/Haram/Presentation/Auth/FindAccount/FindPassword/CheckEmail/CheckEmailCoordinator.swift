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
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CheckEmailViewController = CheckEmailViewController(
      viewModel: CheckEmailViewModel(
        payload: .init(userMail: ""),
        dependency: .init(authRepository: AuthRepositoryImpl())
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}
