//
//  Ex + KeyboardResponder.swift
//  Haram
//
//  Created by 이건준 on 10/17/23.
//

import UIKit

protocol KeyboardResponder {
  var targetView: UIView { get }
}

extension KeyboardResponder where Self: BaseViewController {
  
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillShow(notification)
    }
    
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillHide(notification)
    }
  }
  
  func removeNotifications() {
//    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self)
  }
  
  func keyboardWillShow(_ notification: Notification) {
    
    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let keyboardHeight = keyboardSize.height
    
    if self.targetView.window?.frame.origin.y == 0 {
      self.targetView.window?.frame.origin.y -= keyboardHeight
    }
    
    
    UIView.animate(withDuration: 1) {
      self.targetView.layoutIfNeeded()
    }
  }
  
  func keyboardWillHide(_ notification: Notification) {
    self.targetView.window?.frame.origin.y = 0
    UIView.animate(withDuration: 1) {
      self.targetView.layoutIfNeeded()
    }
  }
}

