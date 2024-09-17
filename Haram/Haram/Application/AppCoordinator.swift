//
//  AppCoordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

import UIKit

final class AppCoordinator: NavigationCoordinator {
  
  private var isLoggedIn: Bool {
    UserManager.shared.hasToken
  }
  
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  required init(navigationController: UINavigationController) {
    self.navigationController = navigationController
    self.navigationController.navigationBar.isHidden = true
    NotificationCenter.default.addObserver(self, selector: #selector(refreshAllToken), name: .refreshAllToken, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func start() {
    isLoggedIn ? showMainTabViewController() : showLoginViewController()
  }
  
  @objc
  private func refreshAllToken() {
    showLoginViewController()
  }
}

extension AppCoordinator {
  private func showLoginViewController() {
    DispatchQueue.main.async {
      let coordinator = LoginCoordinator(navigationController: self.navigationController)
      coordinator.delegate = self
      coordinator.parentCoordinator = self
      coordinator.start()
      self.childCoordinators.append(coordinator)
    }
  }
  
  private func showMainTabViewController() {
    let coordinator = MainTabCoordinator(navigationController: self.navigationController)
    coordinator.delegate = self
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}

extension AppCoordinator: LoginCoordinatorDelegate {
  func didFinishLogin() {
    childCoordinators.removeAll()
    showMainTabViewController()
  }
}

extension AppCoordinator: MainTabCoordinatorDelegate {
  func didRequestLogout() {
    childCoordinators.removeAll()
    showLoginViewController()
  }
}
