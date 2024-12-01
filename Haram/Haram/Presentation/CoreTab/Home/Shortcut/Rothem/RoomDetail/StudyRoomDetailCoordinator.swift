//
//  StudyRoomDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class StudyRoomDetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let studyRoomModel: StudyListCollectionViewCellModel
  
  init(studyRoomModel: StudyListCollectionViewCellModel, navigationController: UINavigationController) {
    self.studyRoomModel = studyRoomModel
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: StudyRoomDetailViewController = StudyRoomDetailViewController(
      viewModel: StudyRoomDetailViewModel(
        dependency: .init(
          rothemRepository: RothemRepositoryImpl(),
          coordinator: self
        ),
        payload: .init(roomSeq: studyRoomModel.roomSeq)
      )
    )
    viewController.title = studyRoomModel.title
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension StudyRoomDetailCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showStudyReservationViewController() {
    let viewController = StudyReservationViewController(
      viewModel: StudyReservationViewModel(
        rothemRepository: RothemRepositoryImpl(),
        roomSeq: studyRoomModel.roomSeq
      )
    )
    viewController.navigationItem.largeTitleDisplayMode = .never
    navigationController.pushViewController(viewController, animated: true)
  }
}
