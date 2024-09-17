//
//  HaramDividerView.swift
//  Haram
//
//  Created by 이건준 on 9/19/24.
//

import UIKit

import SnapKit
import Then

final class HaramDividerView: UIView {
  
  lazy var lineView = UIView().then { view in
    view.backgroundColor = .hexF1F3F3
  }
  
  init(thickness: CGFloat, isVertical: Bool) {
    super.init(frame: .zero)
    self.setUpView(thickness: thickness, isVertical: isVertical)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpView(thickness: CGFloat, isVertical: Bool) {
    if isVertical {
      self.snp.makeConstraints {
        $0.width.equalTo(thickness)
      }
    } else {
      self.snp.makeConstraints {
        $0.height.equalTo(thickness)
      }
    }
    
    self.addSubview(lineView)
    lineView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

extension UIStackView {
  func addArrangedDividerSubViews(_ views: [UIView], exclude: [Int]? = [], thickness: CGFloat = 1.0, isVertical: Bool = false) {
    self.addArrangedSubviews(views, exclude ?? [], divier: { HaramDividerView(thickness: thickness, isVertical: isVertical) })
  }
  
  func insertArrangedDividerSubView(_ view: UIView, index: Int, thickness: CGFloat = 1.0, isVertical: Bool = false) {
    self.insertArrangedSubview(view, at: index, divider: { HaramDividerView(thickness: thickness, isVertical: isVertical) })
  }
}
