//
//  AlertManager.swift
//  Haram
//
//  Created by 이건준 on 3/6/24.
//

import UIKit

/// 메시지 타입 정의
public enum MessageType: CustomStringConvertible, Equatable {
  case needSignIn
  case custom(String)
  
  public var description: String {
    switch self {
    case .needSignIn:
      return "로그인이 필요합니다."
    case .custom(let string):
      return string
    }
  }
}

/// 버튼 타입 정의
public enum AlertButtonType {
  case confirm(title: String = "확인")
  case cancel(title: String = "취소")
}

/// AlertManager 정의
public final class AlertManager {
  
  // MARK: - Public API
  
  /// Show a common alert
  public static func showAlert(
    on viewController: UIViewController? = nil,
    title: String = "Space 알림",
    message: MessageType,
    actions: [AlertButtonType] = [.confirm()],
    confirmHandler: (() -> Void)? = nil,
    cancelHandler: (() -> Void)? = nil
  ) {
    let alertController = UIAlertController(
      title: title,
      message: message.description,
      preferredStyle: .alert
    )
    
    actions.forEach { actionType in
      let action = createAction(type: actionType, confirmHandler: confirmHandler, cancelHandler: cancelHandler)
      alertController.addAction(action)
    }
    
    present(alertController, on: viewController)
  }
  
  // MARK: - Private Methods
  
  /// Create an alert action based on type
  private static func createAction(
    type: AlertButtonType,
    confirmHandler: (() -> Void)?,
    cancelHandler: (() -> Void)?
  ) -> UIAlertAction {
    switch type {
    case .confirm(let title):
      return UIAlertAction(title: title, style: .default) { _ in
        confirmHandler?()
      }
    case .cancel(let title):
      return UIAlertAction(title: title, style: .cancel) { _ in
        cancelHandler?()
      }
    }
  }
  
  /// Present alert on the given view controller
  private static func present(_ alert: UIAlertController, on viewController: UIViewController?) {
    DispatchQueue.main.async {
      if let viewController = viewController {
        viewController.present(alert, animated: true)
      } else {
        UIApplication.getTopViewController()?.present(alert, animated: true)
      }
    }
  }
}

// MARK: - UIApplication Extension

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
