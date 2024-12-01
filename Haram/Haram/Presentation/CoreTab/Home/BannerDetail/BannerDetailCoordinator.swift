//
//  BannerDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/23/24.
//

import UIKit

final class BannerDetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let bannerSeq: Int
  private let title: String
  
  init(
    title: String,
    bannerSeq: Int,
    navigationController: UINavigationController
  ) {
    self.title = title
    self.bannerSeq = bannerSeq
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BannerDetailViewController = BannerDetailViewController(
      viewModel: HomeBannerDetailViewModel(
        payload: .init(bannerSeq: bannerSeq),
        dependency: .init(
          noticeRepository: NoticeRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.title = title
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension BannerDetailCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
