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
  case networkUnavailable
  case zoomUnavailable
  case custom(String)
  
  public var description: String {
    switch self {
    case .needSignIn:
      return "로그인이 필요합니다."
    case .networkUnavailable:
      return "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."
    case .zoomUnavailable:
      return "해당 이미지는 확대할 수 없습니다"
    case .custom(let string):
      return string
    }
  }
}

public final class AlertManager {
  
  // MARK: - Private Methods
  
  private static func createAction(configuration: AlertButtonConfigurable) -> UIAlertAction {
    return UIAlertAction(
      title: configuration.title,
      style: configuration.style,
      handler: { _ in configuration.handler?() }
    )
  }
  
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

protocol AlertPresentable {
  static func showAlert(
    on viewController: UIViewController?,
    title: String,
    message: MessageType,
    actions: [AlertButtonConfigurable]
  )
}

extension AlertManager: AlertPresentable {
  static func showAlert(
    on viewController: UIViewController? = nil,
    title: String = "Space 알림",
    message: MessageType,
    actions: [AlertButtonConfigurable] = [DefaultAlertButton()]
  ) {
    let alertController = UIAlertController(
      title: title,
      message: message.description,
      preferredStyle: .alert
    )
    
    actions.forEach { configuration in
      let action = createAction(configuration: configuration)
      alertController.addAction(action)
    }
    
    present(alertController, on: viewController)
  }
}
