//
//  LoginCoordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
  func didFinishLogin()
}

final class LoginCoordinator: Coordinator {
  weak var delegate: LoginCoordinatorDelegate?
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LoginViewController = LoginViewController(
      viewModel: LoginViewModel(
        dependency: .init(
          coordinator: self,
          authRepository: AuthRepositoryImpl()
        )
      )
    )
    self.navigationController.setViewControllers([viewController], animated: false)
  }
}

extension LoginCoordinator {
  func didFinishLogin() {
    delegate?.didFinishLogin()
  }
  
  func showTermsOfUseViewController() {
    let coordinator = TermsOfUseCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showFindAccountViewController() {
    let coordinator = FindAccountCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
