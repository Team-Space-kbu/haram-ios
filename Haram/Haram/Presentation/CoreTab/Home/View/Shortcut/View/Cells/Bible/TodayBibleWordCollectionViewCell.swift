//
//  TodayBibleWordCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class TodayBibleWordCollectionViewCell: UICollectionViewCell {
  static let identifier = "TodayBibleWordCollectionViewCell"
  
  private let todayBibleWordLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.skeletonTextNumberOfLines = 3
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    todayBibleWordLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
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
