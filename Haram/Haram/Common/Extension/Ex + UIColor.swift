//
//  Ex + UIColor.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

// MARK: - Init

extension UIColor {
  
  /// 16진수(hex code)를 이용하여 색상을 지정합니다.
  ///
  /// ```
  /// let color: UIColor = UIColor(hex: 0xF5663F)
  /// ```
  /// - Parameters:
  ///   - hex: 16진수의 Unsigned Int 값
  ///   - alpha: 투명도를 설정합니다. 0과 1사이의 값을 가져야합니다.
  convenience init(hex: UInt, alpha: CGFloat = 1.0) {
    self.init(
      red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(hex & 0x0000FF) / 255.0,
      alpha: CGFloat(alpha)
    )
  }
  
  static var ramdomColor: UIColor {
    return UIColor(
      red: CGFloat.random(in: 0.5...1),
      green: CGFloat.random(in: 0.5...1),
      blue: CGFloat.random(in: 0.5...1),
      alpha: 1
    )
  }
}

// MARK: - Plub Color Palette

extension UIColor {
  static let hex3B8686          = UIColor(hex: 0x3B8686)
  static let hex79BD9A          = UIColor(hex: 0x79BD9A)
  static let hexA8DBA8          = UIColor(hex: 0xA8DBA8)
  static let hexCFF09E          = UIColor(hex: 0xCFF09E)
  static let hex56CCF2          = UIColor(hex: 0x56CCF2)
  static let hex2D9CDB          = UIColor(hex: 0x2D9CDB)
  static let hex2F80ED          = UIColor(hex: 0x2F80ED)
  static let hexF8F8F8          = UIColor(hex: 0xF8F8F8)
  static let hexD8D8DA          = UIColor(hex: 0xD8D8DA)
  static let hex545E6A          = UIColor(hex: 0x545E6A)
  static let hex1A1E27          = UIColor(hex: 0x1A1E27)
  static let hex9F9FA4          = UIColor(hex: 0x9F9FA4)
  static let hexF2F3F5          = UIColor(hex: 0xF2F3F5)
  static let hexF2D96D          = UIColor(hex: 0xF2D96D)
  static let hex42A9C2          = UIColor(hex: 0x42A9C2)
  static let hex458FCC          = UIColor(hex: 0x458FCC)
  static let hex4548CC          = UIColor(hex: 0x4548CC)
  static let hex6242C2          = UIColor(hex: 0x6242C2)
  static let hex4666B5          = UIColor(hex: 0x4666B5)
  static let hexF5F5F5          = UIColor(hex: 0xF5F5F5)
  static let hexD0D0D0          = UIColor(hex: 0xD0D0D0)
  static let hexD6D4D6          = UIColor(hex: 0xD6D4D6)
  static let hex4B81EE          = UIColor(hex: 0x4B81EE)
  static let hex1477F9          = UIColor(hex: 0x1477F9)
  static let hex707070          = UIColor(hex: 0x707070)
  static let hex02162E          = UIColor(hex: 0x02162E)
  static let hexEEF0F3          = UIColor(hex: 0xEEF0F3)
  static let hexF02828          = UIColor(hex: 0xF02828)
  static let hex95989A          = UIColor(hex: 0x95989A)
  static let hex8B8B8E          = UIColor(hex: 0x8B8B8E)
  static let hexC9C9C9          = UIColor(hex: 0xC9C9C9)
  static let hexD9D9D9          = UIColor(hex: 0xD9D9D9)
  static let hexF4F4F4          = UIColor(hex: 0xF4F4F4)
  static let hex83A3E4          = UIColor(hex: 0x83A3E4)
  static let hexE28B7B          = UIColor(hex: 0xE28B7B)
  static let hex9B87DB          = UIColor(hex: 0x9B87DB)
  static let hex8BC88E          = UIColor(hex: 0x8BC88E)
  static let hexF0AF72          = UIColor(hex: 0xF0AF72)
  static let hex90CFC1          = UIColor(hex: 0x90CFC1)
  static let hexD397ED          = UIColor(hex: 0xD397ED)
  static let hexA7CA70          = UIColor(hex: 0xA7CA70)
  static let hexF1F3F3          = UIColor(hex: 0xF1F3F3)
  static let hexFFB6B6          = UIColor(hex: 0xFFB6B6)
  static let hex2F2E41          = UIColor(hex: 0x2F2E41)
  static let hex898A8D          = UIColor(hex: 0x898A8D)
}

