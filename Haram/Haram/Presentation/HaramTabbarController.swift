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
  
  private let homeViewController = NavigationController(rootViewController: HomeViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "성서알리미",
      image: UIImage(named: "home"),
      tag: 0
    )
  })
  
  private let boardViewController = NavigationController(rootViewController: BoardViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "게시판",
      image: UIImage(named: "board"),
      tag: 2
    )
  })
  
  private let moreViewController = NavigationController(rootViewController: MoreViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "더보기",
      image: UIImage(named: "more"),
      tag: 3
    )
  })
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  private func setupLayouts() {
    
    viewControllers = [
      homeViewController,
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
        $0.normal.titleTextAttributes = [.font: UIFont.medium10, .foregroundColor: UIColor.hex95989A]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.regular10, .foregroundColor: UIColor.hex79BD9A]
      }
    }
    delegate = self
  }
}
extension HaramTabbarController: UITabBarControllerDelegate {
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    guard let fromView = tabBarController.selectedViewController?.view,
          let toView = viewController.view else { return false }
    
    if fromView == toView {
      return false
    } else {
      UIView.transition(from: fromView, to: toView, duration: 0.2, options: .transitionCrossDissolve)
      
      return true
    }
  }
}
  
