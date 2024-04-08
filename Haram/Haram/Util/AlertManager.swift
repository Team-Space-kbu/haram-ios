//
//  AlertManager.swift
//  Haram
//
//  Created by 이건준 on 3/6/24.
//

import UIKit

final class AlertManager {
  
  private init() {}
  
  static func showAlert(title: String, message: String? = nil, viewController: BaseViewController, confirmHandler: (() -> Void)?, cancelHandler: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: { _ in
      cancelHandler?()
    }))
    
    if let confirmHandler = confirmHandler {
      alert.addAction(UIAlertAction(title: "네", style: .destructive, handler: { _ in
        confirmHandler()
      }))
    }
    
    viewController.present(alert, animated: true)
  }
  
  static func showAlert(title: String, message: String? = nil, viewController: BaseViewController?, confirmHandler: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
      confirmHandler?()
    }))
    
    DispatchQueue.main.async {
      if let viewController = viewController {
        viewController.present(alert, animated: true)
      } else {
        let viewController = UIApplication.getTopViewController()
        viewController?.present(alert, animated: true)
      }
    }
  }
  
}

public extension UIApplication {
  static var keyWindow: UIWindow? {
    return UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
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
