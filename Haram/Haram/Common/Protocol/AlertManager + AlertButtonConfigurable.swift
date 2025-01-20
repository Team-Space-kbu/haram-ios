//
//  AlertManager + AlertButtonConfigurable.swift
//  Haram
//
//  Created by 이건준 on 1/21/25.
//

import UIKit

protocol AlertButtonConfigurable {
  var title: String { get }
  var style: UIAlertAction.Style { get }
  var handler: (() -> Void)? { get }
}

struct DefaultAlertButton: AlertButtonConfigurable {
  let title: String
  let style: UIAlertAction.Style
  let handler: (() -> Void)?
  
  init(title: String = "확인", style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
    self.title = title
    self.style = style
    self.handler = handler
  }
}

struct DestructiveAlertButton: AlertButtonConfigurable {
  let title: String
  let style: UIAlertAction.Style
  let handler: (() -> Void)?
  
  init(title: String = "확인", style: UIAlertAction.Style = .destructive, handler: (() -> Void)? = nil) {
    self.title = title
    self.style = style
    self.handler = handler
  }
}

struct CancelAlertButton: AlertButtonConfigurable {
  let title: String
  let style: UIAlertAction.Style
  let handler: (() -> Void)?
  
  init(title: String = "취소", style: UIAlertAction.Style = .cancel, handler: (() -> Void)? = nil) {
    self.title = title
    self.style = style
    self.handler = handler
  }
}
