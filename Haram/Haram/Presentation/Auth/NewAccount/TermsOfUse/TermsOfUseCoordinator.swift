//
//  TermsOfUseCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/18/24.
//

import UIKit

final class TermsOfUseCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: TermsOfUseViewController = TermsOfUseViewController(
      viewModel: TermsOfUseViewModel(
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension TermsOfUseCoordinator {
  func showNewAccountViewController() {
    let coordinator = NewAccountCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
