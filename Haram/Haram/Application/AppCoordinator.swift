//
//  AppCoordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

//import UIKit
//
//final class AppCoordinator: Coordinator {
//  
//  private var isLoggedIn: Bool {
//    UserManager.shared.hasToken
//  }
//  
//  var navigationController: UINavigationController
//  var parentCoordinator: Coordinator?
//  var childCoordinators: [Coordinator] = []
//  
//  init(navigationController: UINavigationController) {
//    self.navigationController = navigationController
//  }
//  
//  func start() {
//    isLoggedIn ? showLoginViewController() : showMainTabViewController()
//  }
//}
//
//extension AppCoordinator {
//  private func showLoginViewController() {
////    let coordinator = LoginCoordinator(navigationController: self.navigationController)
////    coordinator.start()
////    self.childCoordinators.append(coordinator)
//  }
//  
//  private func showMainTabViewController() {
////    let coordinator = MainTabCoordinator(navigationController: self.navigationController)
////    coordinator.start()
////    self.childCoordinators.append(coordinator)
//  }
//}
