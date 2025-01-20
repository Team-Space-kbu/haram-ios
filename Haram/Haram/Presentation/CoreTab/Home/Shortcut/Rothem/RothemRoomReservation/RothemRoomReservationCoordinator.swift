//
//  RothemRoomReservationCoordinator.swift
//  Haram
//
//  Created by 이건준 on 12/17/24.
//

import UIKit

final class RothemRoomReservationCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let roomSeq: Int
  
  init(roomSeq: Int, navigationController: UINavigationController) {
    self.roomSeq = roomSeq
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController = RothemRoomReservationViewController(
      viewModel: RothemRoomReservationViewModel(
        payload: .init(roomSeq: roomSeq),
        dependency: .init(
          rothemRepository: RothemRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.navigationItem.largeTitleDisplayMode = .never
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension RothemRoomReservationCoordinator {
  func showZoomImageViewController(imageURL: URL) {
    let modal = ZoomImageViewController(zoomImageURL: imageURL)
    modal.modalPresentationStyle = .fullScreen
    navigationController.present(modal, animated: true)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func popToRothemListViewController() {
    let viewController = self.navigationController.viewControllers[1]
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popToViewController(viewController, animated: true)
  }
}
