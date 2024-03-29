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
    layer.shadowColor = UIColor.black.withAlphaComponent(0.16).cgColor
    layer.shadowOffset = shadowOffset
  }
}
