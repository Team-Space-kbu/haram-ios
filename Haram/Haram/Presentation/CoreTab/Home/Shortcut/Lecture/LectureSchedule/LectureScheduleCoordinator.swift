//
//  LectureScheduleCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/18/24.
//

import UIKit

final class LectureScheduleCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let classRoom: String
  
  init(classRoom: String, navigationController: UINavigationController) {
    self.classRoom = classRoom
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LectureScheduleViewController = LectureScheduleViewController(
      viewModel: LectureScheduleViewModel(
        payload: .init(classRoom: classRoom),
        dependency: .init(
          lectureRepository: LectureRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.title = classRoom
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension LectureScheduleCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
