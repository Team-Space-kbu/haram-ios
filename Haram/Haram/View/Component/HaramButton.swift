//
//  HaramButton.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import UIKit

import SnapKit
import Then

enum HaramButtonType {
  case apply
  case cancel
}

final class HaramButton: UIButton {

  private var type: HaramButtonType {
    didSet {
      configureUI()
    }
  }
  
  init(type: HaramButtonType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    switch type {
      case .apply:
        backgroundColor = .hex79BD9A
      case .cancel:
        backgroundColor = .hex9F9FA4
    }
    
    setTitleColor(.white, for: .normal)
    layer.cornerRadius = 10
    layer.masksToBounds = true
  }
  
  func setTitleText(title: String) {
    let attributedString = NSAttributedString(
      string: title,
      attributes: [.font: UIFont.bold14]
    )
    setTitle(attributedString.string, for: .normal)
  }
  
  func setupButtonType(type: HaramButtonType) {
    self.type = type
  }
}
