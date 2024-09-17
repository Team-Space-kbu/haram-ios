//
//  CampusBuildingListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

import UIKit

final class CampusBuildingListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
      self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CampusBuildingListViewController = CampusBuildingListViewController(
      viewModel: CampusBuildingListViewModel(
        dependency: .init(
          lectureRepository: LectureRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension CampusBuildingListCoordinator {
  func goToLectureListViewController(type: ClassType) {
    let coordinator = LectureListCoordinator(
      classRoom: type.rawValue,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
