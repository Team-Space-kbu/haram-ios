//
//  ChapelDetailCell.swift
//  Haram
//
//  Created by 이건준 on 9/22/24.
//

import UIKit

import SnapKit
import Then

final class ChapelDetailCell: UICollectionViewCell, ReusableView {
  
  private let titleLabel = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .hex9F9FA4
    $0.font = .regular16
  }
  
  private let dayLabel = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .hex545E6A
    $0.font = .bold16
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    isSkeletonable = true
    skeletonCornerRadius = 15
    [titleLabel, dayLabel].forEach { contentView.addSubview($0) }
    
    titleLabel.snp.makeConstraints {
      $0.top.greaterThanOrEqualToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(contentView.snp.centerY).offset(-1)
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(2)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    contentView.backgroundColor = .hexF4F4F4
    contentView.layer.cornerRadius = 15
    contentView.layer.masksToBounds = true
  }
}

// MARK: - Data Configuration

struct ChapelDetailCellModel {
  let title: String
  let day: String
}

extension ChapelDetailCell {
  func configureUI(with model: ChapelDetailCellModel) {
    titleLabel.text = model.title
    dayLabel.text = model.day
  }
}
