//
//  MainTabCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/8/24.
//

import UIKit

protocol MainTabCoordinatorDelegate: AnyObject {
  func didRequestLogout()
}

final class MainTabCoordinator: Coordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  weak var delegate: MainTabCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let tabbarController: HaramTabbarController = HaramTabbarController()
    let homeCoordinator = HomeCoordinator(navigationController: NavigationController())
    let boardCoordinator = BoardCoordinator(navigationController: NavigationController())
    let mypageCoordinator = MyPageCoordinator(navigationController: NavigationController())
    
    mypageCoordinator.delegate = self
    
    let tabCoordinators: [NavigationCoordinator] = [
      homeCoordinator,
      boardCoordinator,
      mypageCoordinator
    ]
    let viewControllers = tabCoordinators.map { $0.navigationController }
    viewControllers[0].tabBarItem = UITabBarItem(
      title: "성서알리미",
      image: UIImage(named: "home"),
      tag: 0
    )
    viewControllers[1].tabBarItem = UITabBarItem(
      title: "게시판",
      image: UIImage(named: "board"),
      tag: 1
    )
    viewControllers[2].tabBarItem = UITabBarItem(
      title: "더보기",
      image: UIImage(named: "more"),
      tag: 2
    )
    
    tabCoordinators.forEach { coordinator in
      coordinator.start()
    }
    
    tabbarController.viewControllers = viewControllers
    
    navigationController.setViewControllers([tabbarController], animated: true)
  }
}

extension MainTabCoordinator: MyPageCoordinatorDelegate {
  func didLogout() {
    delegate?.didRequestLogout()
  }
}
