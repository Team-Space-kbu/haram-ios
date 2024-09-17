//
//  NavigationController.swift
//  Haram
//
//  Created by 이건준 on 11/6/24.
//

import UIKit

class NavigationController: UINavigationController {
  
  override func viewDidLoad() {
    interactivePopGestureRecognizer?.delegate = self
  }
}

extension NavigationController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }
}

