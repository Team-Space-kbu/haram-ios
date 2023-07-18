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
  
  private let userID: String
  
  private lazy var homeViewController = UINavigationController(rootViewController: HomeViewController().then {
    $0.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
  })
  
  private lazy var scheduleViewController = UINavigationController(rootViewController: ScheduleViewController().then {
    $0.tabBarItem = UITabBarItem(title: "시간표", image: UIImage(named: "time"), tag: 1)
  })
  
  private lazy var boardViewController = UINavigationController(rootViewController: BoardViewController().then {
    $0.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(named: "board"), tag: 2)
  })
  
  private lazy var moreViewController = UINavigationController(rootViewController: MoreViewController(userID: userID).then {
    $0.tabBarItem = UITabBarItem(title: "더보기", image: UIImage(named: "more"), tag: 3)
  } )
  
  init(userID: String) {
    self.userID = userID
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
        $0.normal.titleTextAttributes = [.font: UIFont.medium]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.regular10]
      }
    }
//    delegate = self
  }
}

//extension HaramTabbarController: UITabBarControllerDelegate {
//  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//    if viewController == scheduleViewController {
//      guard !UserManager.shared.hasIntranetToken else { return }
//      let vc = IntranetLoginViewController()
//      vc.navigationItem.largeTitleDisplayMode = .never
//      print("시발 \(scheduleViewController.navigationController)")
//      self.navigationController?.pushViewController(vc, animated: true)
//    }
//  }
//}
