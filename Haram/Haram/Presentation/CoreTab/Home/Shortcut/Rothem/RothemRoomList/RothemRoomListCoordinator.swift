//
//  RothemRoomListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/21/24.
//

import UIKit

final class RothemRoomListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: RothemRoomListViewController = RothemRoomListViewController(
      viewModel: RothemRoomListViewModel(
        dependency: .init(
          rothemRepository: RothemRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension RothemRoomListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showBannerDetailViewController(bannerSeq: Int) {
    let coordinator = BannerDetailCoordinator(
      title: "스터디 공지사항",
      bannerSeq: bannerSeq,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showCheckReservationViewController() {
    let coordinator = CheckReservationCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showRoomDetailViewController(studyRoomModel: StudyListCollectionViewCellModel) {
    let coordinator = RothemRoomDetailCoordinator(
      studyRoomModel: studyRoomModel,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
