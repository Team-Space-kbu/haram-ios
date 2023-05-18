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
  static let bold = UIFont(name: SpoqaHanSansNeo.bold.rawValue, size: 20)!
  static let medium = UIFont(name: SpoqaHanSansNeo.medium.rawValue, size: 10)!
  static let regular = UIFont(name: SpoqaHanSansNeo.regular.rawValue, size: 10)!
  static let light = UIFont(name: SpoqaHanSansNeo.light.rawValue, size: 12)!
  static let thin = UIFont(name: SpoqaHanSansNeo.thin.rawValue, size: 10)!
}
