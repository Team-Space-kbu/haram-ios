//
//  MyPageCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/8/24.
//

import UIKit

protocol MyPageCoordinatorDelegate: AnyObject {
  func didLogout()
}

final class MyPageCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  weak var delegate: MyPageCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: MoreViewController = MoreViewController(
      viewModel: MoreViewModel(
        dependency: .init(
          authRepository: AuthRepositoryImpl(),
          myPageRepository: MyPageRepositoryImpl(),
          coordinator: self
        )))
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension MyPageCoordinator {
  func goToLoginViewController() {
    delegate?.didLogout()
  }
  
  func showMoreCategoryViewController(title: String, noticeType: NoticeType) {
    let coordinator = MoreCategoryCoordinator(
      title: title, 
      noticeType: noticeType,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
  
  func showHaramProvisionViewController(url: URL?, title: String) {
    let vc = HaramProvisionViewController(url: url)
    vc.title = title
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  func showCustomAcknowViewController() {
    let acknowList = CustomAcknowListViewController(fileNamed: Constants.openLicenseFileName)
    acknowList.title = "오픈소스 라이센스"
    acknowList.hidesBottomBarWhenPushed = true 
    self.navigationController.pushViewController(acknowList, animated: true)
  }
  
  func showUpdatePasswordViewController() {
    let vc = MoreUpdatePasswordViewController()
    vc.modalPresentationStyle = .fullScreen
    vc.hidesBottomBarWhenPushed = true
    navigationController.present(vc, animated: true)
  }
  
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(title: title, message: message, viewController: self.navigationController, confirmHandler: confirmHandler, cancelHandler: nil)
  }
}
