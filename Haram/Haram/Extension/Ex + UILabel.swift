//
//  Ex + UILabel.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import UIKit

extension UILabel {
  
  /// UILabel의 줄 간격을 설정합니다.
  /// - Parameters:
  ///   - lineSpacing: UILabel의 줄 간격
  ///   - string: UILabel에 설정할 텍스트
  func addLineSpacing(lineSpacing: CGFloat, string: String) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing

    let attributedString = NSAttributedString(
      string: string,
      attributes: [.paragraphStyle: paragraphStyle]
    )
    
    self.attributedText = attributedString
  }
}
