//
//  ChapelCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/20/24.
//

import UIKit

final class ChapelCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: ChapelViewController = ChapelViewController(
      viewModel: ChapelViewModel(
        dependency: .init(
          intranetRepository: IntranetRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension ChapelCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}

