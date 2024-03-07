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
  
  static func showAlert(title: String, message: String? = nil, viewController: BaseViewController, confirmHandler: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
      confirmHandler?()
    }))
    
    viewController.present(alert, animated: true)
  }
  
}
