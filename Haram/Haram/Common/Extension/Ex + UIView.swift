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
  }
  
  func showAnimation(scale: CGFloat = 0.95, completion: @escaping () -> Void) {
    isUserInteractionEnabled = false
    
    animateView(alpha: 0.5, scale: scale, duration: 0.1) { [weak self] in
      self?.animateView(alpha: 1.0, scale: 1.0, duration: 0.1) { [weak self] in
        self?.isUserInteractionEnabled = true
        completion()
      }
    }
  }
  
  func animateView(alpha: CGFloat, scale: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
    UIView.animate(
      withDuration: duration,
      delay: 0,
      options: .curveLinear,
      animations: {
        self.alpha = alpha
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
      },
      completion: { _ in
        completion()
      }
    )
  }
  
  func showColorAnimation(originalColor: UIColor, scale: CGFloat = 0.98, _ completionBlock: @escaping () -> Void) {
    isUserInteractionEnabled = false
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveLinear,
      animations: { [weak self] in
        self?.backgroundColor = .lightGray
        self?.transform = CGAffineTransform.init(scaleX: scale, y: scale)
      }) {  (done) in
        UIView.animate(
          withDuration: 0.1,
          delay: 0,
          options: .curveLinear,
          animations: { [weak self] in
            self?.backgroundColor = originalColor
            self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
          }) { [weak self] (_) in
            self?.isUserInteractionEnabled = true
            completionBlock()
          }
      }
  }
}
