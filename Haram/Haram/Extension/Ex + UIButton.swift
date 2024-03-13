//
//  Ex + UIButton.swift
//  Haram
//
//  Created by 이건준 on 3/13/24.
//

import UIKit

import Then

// MARK: - Conform Then

extension UIButton.Configuration: Then { }
extension UIBackgroundConfiguration: Then { }
extension AttributedString: Then { }
extension AttributeContainer: Then { }

extension UIButton.Configuration {
  
  var font: UIFont? {
    get {
      self.attributedTitle?.font
    }
    set {
      self.attributedTitle?.font = newValue
    }
  }
  
  // MARK: Configuration Return Type
  
  /// 회색으로 fill되어있는 Haram 버튼
  /// - Parameters:
  ///   - title: 버튼 내부의 text
  ///   - contentInsets: 버튼 내부 text와 버튼 테두리 사이의 inset
  static func cancelFilledButton(title: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.Configuration {
    var style = UIButton.Configuration.filled()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex9F9FA4
    }
    
    style.contentInsets = contentInsets
    style.baseForegroundColor = .white
    style.title = title
    style.font = .bold14
    return style
  }
  
  static func haramFilledButton(title: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.Configuration {
    var style = UIButton.Configuration.filled()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex79BD9A
    }
    
    style.contentInsets = contentInsets
    style.baseForegroundColor = .white
    style.title = title
    style.font = .bold14
    return style
  }
  
  
  
  private static func haramButtonEnabled() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex79BD9A
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  private static func haramButtonDisabled() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex9F9FA4
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  func haramButton(label text: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .haramButtonEnabled()
      case .disabled:
        button.configuration = .haramButtonDisabled()
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .bold14
      button.configuration?.contentInsets = contentInsets
    }
  }
}
