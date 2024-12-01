//
//  LectureListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/18/24.
//

import UIKit

final class LectureListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let classRoom: String
  
  init(classRoom: String, navigationController: UINavigationController) {
    self.classRoom = classRoom
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LectureListViewController = LectureListViewController(
      viewModel: LectureListViewModel(
        payload: .init(classRoom: classRoom),
        dependency: .init(
          lectureRepository: LectureRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension LectureListCoordinator {
  func showLectureScheduleViewController(classRoom: String) {
    let coordinator = LectureScheduleCoordinator(
      classRoom: classRoom,
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
