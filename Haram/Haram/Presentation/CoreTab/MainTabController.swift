//
//  MainTabController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class MainTabController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStyles()
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
extension MainTabController: UITabBarControllerDelegate {
  
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
  
