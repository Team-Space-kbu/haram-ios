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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  private func setupLayouts() {
    viewControllers = [
      HomeViewController().then {
        $0.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
      },
      ScheduleViewController().then {
        $0.tabBarItem = UITabBarItem(title: "시간표", image: UIImage(named: "time"), tag: 1)
      },
      BoardViewController().then {
        $0.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(named: "board"), tag: 2)
      },
      MoreViewController().then {
        $0.tabBarItem = UITabBarItem(title: "더보기", image: UIImage(named: "more"), tag: 3)
      }
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
        $0.normal.titleTextAttributes = [.font: UIFont.medium]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.regular]
      }
    }
  }
}
