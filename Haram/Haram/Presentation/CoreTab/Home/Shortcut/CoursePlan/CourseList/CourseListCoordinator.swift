//
//  CourseListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/22/24.
//

import UIKit

final class CourseListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let course: String
  private let title: String
  
  init(course: String, title: String, navigationController: UINavigationController) {
    self.course = course
    self.title = title
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: CourseListViewController = CourseListViewController(
      viewModel: CourseListViewModel(
        payload: .init(course: course),
        dependency: .init(
          lectureRepository: LectureRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.title = title
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension CourseListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showPDFViewController(pdfURL: URL?, title: String) {
    let vc = PDFViewController(pdfURL: pdfURL)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    navigationController.pushViewController(vc, animated: true)
  }
}
