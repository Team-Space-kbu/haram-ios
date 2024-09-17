//
//  RothemRoomDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class RothemRoomDetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let studyRoomModel: StudyListCollectionViewCellModel
  
  init(studyRoomModel: StudyListCollectionViewCellModel, navigationController: UINavigationController) {
    self.studyRoomModel = studyRoomModel
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: RothemRoomDetailViewController = RothemRoomDetailViewController(
      viewModel: RothemRoomDetailViewModel(
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

extension RothemRoomDetailCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showStudyReservationViewController() {
    let coordinator = RothemRoomReservationCoordinator(roomSeq: studyRoomModel.roomSeq, navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
