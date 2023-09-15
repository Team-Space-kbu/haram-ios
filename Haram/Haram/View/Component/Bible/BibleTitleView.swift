//
//  BibleTitleView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/13.
//

import UIKit

import SnapKit
import Then

struct BibleTitleViewModel {
  let title: String
  let chapter: String
}

final class BibleTitleView: UIView {
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hex1A1E27
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold24
  }
  
  private let chapterLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.font = .regular20
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [lineView, titleLabel, chapterLabel].forEach { addSubview($0) }
    lineView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.width.equalTo(3)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(lineView.snp.trailing).offset(5)
      $0.centerY.equalToSuperview()
    }
    
    chapterLabel.snp.makeConstraints {
      $0.leading.equalTo(titleLabel.snp.trailing)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: BibleTitleViewModel) {
    titleLabel.text = model.title
    chapterLabel.text = model.chapter + "장"
  }
}
