//
//  FindIDResultCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/10/24.
//

import UIKit

final class FindIDResultCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let userMail: String
  private let authCode: String
  
  init(userMail: String, authCode: String, navigationController: UINavigationController) {
    self.userMail = userMail
    self.authCode = authCode
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: FindIDResultViewController = FindIDResultViewController(
      viewModel: FindIDResultViewModel(
        payload: .init(
          userMail: userMail,
          authCode: authCode
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

extension FindIDResultCoordinator {
  func popToRootViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToRootViewController(animated: true)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
