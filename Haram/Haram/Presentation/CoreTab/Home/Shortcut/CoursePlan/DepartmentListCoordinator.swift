//
//  CoursePlanCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class DepartmentListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: DepartmentListViewController = DepartmentListViewController(
      viewModel: DepartmentListViewModel(
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

extension DepartmentListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showLectureInfoViewController(course: String, title: String) {
    let coordinator = CourseListCoordinator(course: course, title: title, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}

