//
//  HaramButton.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import UIKit

import SnapKit
import Then

final class HaramButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .hex79BD9A
    layer.masksToBounds = true
    layer.cornerRadius = 10
    setTitleColor(.white, for: .normal)
  }
  
  func setTitleText(title: String) {
    let attributedString = NSAttributedString(
      string: title,
      attributes: [.font: UIFont.bold14]
    )
    setTitle(attributedString.string, for: .normal)
  }
}
