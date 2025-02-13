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
  
  /// 라벨로 된 Haram 버튼
  /// - Parameters:
  ///   - title: 버튼 내부의 text
  ///   - font: 버튼 text의 폰트
  ///   - forgroundColor: 버튼 text의 색상
  static func haramLabelButton(title: String, font: UIFont = .regular14, forgroundColor: UIColor = .black) -> UIButton.Configuration {
    var style = UIButton.Configuration.filled()
    
    style.background = style.background.with {
      $0.backgroundColor = .clear
    }
    
    style.contentInsets = .zero
    style.baseForegroundColor = forgroundColor
    style.title = title
    style.font = font
    return style
  }
  
  private static func haramCancelButtonEnabled() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex9F9FA4
    }
    style.baseForegroundColor = .white
    
    return style
  }
  
  private static func cancelButtonHighlighted() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex9F9FA4.withAlphaComponent(0.5)
    }
    
    style.baseForegroundColor = .white
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
  
  private static func buttonHighlighted() -> UIButton.Configuration {
    var style = UIButton.Configuration.plain()
    
    style.background = style.background.with {
      $0.cornerRadius = 10
      $0.backgroundColor = .hex79BD9A.withAlphaComponent(0.5)
    }
    
    style.baseForegroundColor = .white
    return style
  }
  
  /// Haram 버튼
  /// - Parameters:
  ///   - text: 버튼 내부의 text
  ///   - contentInsets: 버튼 내부 Inset
  func haramButton(label text: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .haramButtonEnabled()
      case .disabled:
        button.configuration = .haramButtonDisabled()
      case .highlighted:
        button.configuration = .buttonHighlighted()
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .bold14
      button.configuration?.contentInsets = contentInsets
    }
  }
  
  /// Haram 취소버튼
  /// - Parameters:
  ///   - text: 버튼 내부의 text
  ///   - contentInsets: 버튼 내부 Inset
  func haramCancelButton(label text: String, contentInsets: NSDirectionalEdgeInsets) -> UIButton.ConfigurationUpdateHandler {
    return { button in
      switch button.state {
      case .normal:
        button.configuration = .haramCancelButtonEnabled()
      case .highlighted:
        button.configuration = .cancelButtonHighlighted()
      default: break
      }
      button.configuration?.title = text
      button.configuration?.font = .bold14
      button.configuration?.contentInsets = contentInsets
    }
  }
}

