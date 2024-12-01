//
//  LectureInfoCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/22/24.
//

import UIKit

final class LectureInfoCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let course: String
  
  init(course: String, navigationController: UINavigationController) {
    self.course = course
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: LectureInfoViewController = LectureInfoViewController(
      viewModel: LectureInfoViewModel(
        payload: .init(course: course),
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

extension LectureInfoCoordinator {
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
