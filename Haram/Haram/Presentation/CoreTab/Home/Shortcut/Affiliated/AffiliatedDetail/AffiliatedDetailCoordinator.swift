//
//  AffiliatedDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/22/24.
//

import UIKit

final class AffiliatedDetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let affiliatedModel: AffiliatedTableViewCellModel
  
  init(affiliatedModel: AffiliatedTableViewCellModel, navigationController: UINavigationController) {
    self.affiliatedModel = affiliatedModel
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: AffiliatedDetailViewController = AffiliatedDetailViewController(
      viewModel: AffiliatedDetailViewModel(
        payload: .init(id: affiliatedModel.id),
        dependency: .init(
          homeRepository: HomeRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.title = affiliatedModel.affiliatedTitle
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension AffiliatedDetailCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
