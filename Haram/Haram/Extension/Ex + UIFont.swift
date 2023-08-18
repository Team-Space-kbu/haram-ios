//
//  Ex + UIFont.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

extension UIFont {
  enum SpoqaHanSansNeo: String {
    
    case bold = "SpoqaHanSansNeo-Bold"
    
    // medium
    case medium = "SpoqaHanSansNeo-Medium"
    
    // regular
    case regular = "SpoqaHanSansNeo-Regular"
    
    // light
    case light = "SpoqaHanSansNeo-Light"
    
    // thin
    case thin = "SpoqaHanSansNeo-Thin"
  }
}

extension UIFont {
  static let bold44 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 44)!
  static let bold36 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 36)!
  static let bold26 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 26)!
  static let bold22 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 22)!
  static let bold20 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 20)!
  static let bold24 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 24)!
  static let bold18 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 18)!
  static let bold16 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 16)!
  static let bold14 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 14)!
  static let bold13 = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 13)!
  static let medium10 = UIFont(name: SpoqaHanSansNeo.medium.rawValue, size: 10)!
  static let medium16 = UIFont(name: SpoqaHanSansNeo.medium.rawValue, size: 16)!
  static let medium18 = UIFont(name: SpoqaHanSansNeo.medium.rawValue, size: 18)!
  static let regular24 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 24)!
  static let regular20 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 20)!
  static let regular18 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 18)!
  static let regular16 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 16)!
  static let regular15 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 15)!
  static let regular14 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 14)!
  static let regular13 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 13)!
  static let regular10 = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 10)!
  static let light = UIFont(name: SpoqaHanSansNeo.light.rawValue, size: 12)!
  static let thin = UIFont(name: SpoqaHanSansNeo.thin.rawValue, size: 10)!
}
