//
//  Ex + UIView.swift
//  Haram
//
//  Created by 이건준 on 11/29/23.
//

import UIKit

extension UIView {
  func addShadow(shadowRadius: CGFloat, shadowOpacity: Float, shadowOffset: CGSize) {
    layer.masksToBounds = false
    layer.shadowRadius = shadowRadius
    layer.shadowOpacity = shadowOpacity
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = shadowOffset
//    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
  }
}
