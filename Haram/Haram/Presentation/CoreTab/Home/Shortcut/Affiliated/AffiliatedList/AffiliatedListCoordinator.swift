//
//  AffiliatedListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class AffiliatedListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: AffiliatedListViewController = AffiliatedListViewController(
      viewModel: AffiliatedListViewModel(
        dependency: .init(
          homeRepository: HomeRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension AffiliatedListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showAffiliatedDetailViewController(affiliatedModel: AffiliatedTableViewCellModel) {
    let coordinator = AffiliatedDetailCoordinator(affiliatedModel: affiliatedModel, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}


