//
//  Ex + UIApplication.swift
//  Haram
//
//  Created by 이건준 on 1/21/25.
//

import UIKit

extension UIApplication {
  static var keyWindow: UIWindow? {
    return UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: (\.isKeyWindow))
  }
  
  // https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
  class func getTopViewController(
    base: UIViewController? = UIApplication.keyWindow?.rootViewController
  ) -> UIViewController? {
    
    if let nav = base as? UINavigationController {
      return getTopViewController(base: nav.visibleViewController)
      
    } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return getTopViewController(base: selected)
      
    } else if let presented = base?.presentedViewController {
      return getTopViewController(base: presented)
    }
    return base
  }
}
