//
//  HomeCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/8/24.
//

import UIKit

final class HomeCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: HomeViewController = HomeViewController(
      viewModel: HomeViewModel(
        dependency: .init(
          homeRepository: HomeRepositoryImpl(),
          intranetRepository: IntranetRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension HomeCoordinator {
  func showPDFViewController(pdfURL: URL?, title: String) {
    let vc = PDFViewController(pdfURL: pdfURL)
    vc.title = title
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  func showEmptyClassViewController() {
    let coordinator = EmptyClassCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showChapelViewController() {
    let coordinator = ChapelCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showNoticeViewController() {
    let coordinator = NoticeCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showLibraryViewController() {
    let coordinator = LibraryCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showCoursePlanViewController() {
    let coordinator = CoursePlanCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showAffiliatedViewController() {
    let coordinator = AffiliatedCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showScheduleViewController() {
    let coordinator = ScheduleCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showRothemViewController() {
    let coordinator = RothemRoomCoordinator(navigationController: self.navigationController)
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showBannerDetailViewController(bannerSeq: Int) {
    let coordinator = BannerDetailCoordinator(
      title: "공지사항",
      bannerSeq: bannerSeq,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
