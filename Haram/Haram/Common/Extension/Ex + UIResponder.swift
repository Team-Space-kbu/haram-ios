//
//  Ex + UIResponder.swift
//  Haram
//
//  Created by 이건준 on 3/10/24.
//

import UIKit

extension UIResponder {
  private struct StaticResponder {
    static weak var responder: UIResponder?
  }
  
  static func getCurrentResponder() -> UIResponder? {
    StaticResponder.responder = nil
    UIApplication.shared.sendAction(#selector(UIResponder.registerResponder), to: nil, from: nil, for: nil)
    return StaticResponder.responder
  }
  
  @objc
  private func registerResponder() {
    StaticResponder.responder = self
  }
}
