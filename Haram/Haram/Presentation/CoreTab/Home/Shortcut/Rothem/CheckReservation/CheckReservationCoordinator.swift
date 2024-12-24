//
//  CheckReservationCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class CheckReservationCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CheckReservationViewController = CheckReservationViewController(
      viewModel: CheckReservationViewModel(
        dependency: .init(
          rothemRepository: RothemRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension CheckReservationCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(on: self.navigationController, message: .custom(message), actions: [.confirm(), .cancel()], confirmHandler: confirmHandler)
  }
}
