//
//  HaramTabbarController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class HaramTabbarController: UITabBarController {
  
  private lazy var homeViewController = UINavigationController(rootViewController: HomeViewController().then {
    $0.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
  })
  
  private lazy var scheduleViewController = UINavigationController(rootViewController: ScheduleViewController().then {
    $0.tabBarItem = UITabBarItem(title: "시간표", image: UIImage(named: "time"), tag: 1)
  })
  
  private lazy var boardViewController = UINavigationController(rootViewController: BoardViewController().then {
    $0.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(named: "board"), tag: 2)
  })
  
  private lazy var moreViewController = UINavigationController(rootViewController: MoreViewController().then {
    $0.tabBarItem = UITabBarItem(title: "더보기", image: UIImage(named: "more"), tag: 3)
  } )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  private func setupLayouts() {
    viewControllers = [
      homeViewController,
      scheduleViewController,
      boardViewController,
      moreViewController
    ]
  }
  
  private func setupConstraints() {
    
  }
  
  private func setupStyles() {
    tabBar.tintColor = .hex79BD9A
    tabBar.backgroundColor = .white
        
    // tab bar appearance
    tabBar.standardAppearance = UITabBarAppearance().then {
      $0.stackedLayoutAppearance = UITabBarItemAppearance().then {
        // Deselected state
        $0.normal.titleTextAttributes = [.font: UIFont.medium10]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.regular10]
      }
    }
    delegate = self
  }
}

extension HaramTabbarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if viewController == scheduleViewController {
      guard !UserManager.shared.hasIntranetToken else { return }
      let vc = IntranetLoginViewController()
      vc.modalPresentationStyle = .fullScreen
      present(vc, animated: true)
    }
  }
}
