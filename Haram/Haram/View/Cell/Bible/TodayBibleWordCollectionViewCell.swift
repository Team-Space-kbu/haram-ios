//
//  TodayBibleWordCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

final class TodayBibleWordCollectionViewCell: UICollectionViewCell {
  static let identifier = "TodayBibleWordCollectionViewCell"
  
  private let todayBibleWordLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(todayBibleWordLabel)
    todayBibleWordLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    todayBibleWordLabel.addLineSpacing(lineSpacing: 3, string: model)
  }
}
