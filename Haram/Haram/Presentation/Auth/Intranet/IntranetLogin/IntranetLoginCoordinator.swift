//
//  IntranetLoginCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/20/24.
//

import UIKit

final class IntranetLoginCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: IntranetLoginViewController = IntranetLoginViewController(
      viewModel: IntranetLoginViewModel(
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

extension IntranetLoginCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func popToRootViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToRootViewController(animated: true)
  }
}
