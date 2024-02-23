//
//  CategoryCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class CategoryCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "CategoryCollectionViewCell"
  
  private let categoryLabel = UILabel().then {
    $0.font = .medium18
    $0.textColor = .hex02162E
    $0.sizeToFit()
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
    contentView.isSkeletonable = true
    contentView.skeletonCornerRadius = 10
    
    contentView.backgroundColor = .hexEEF0F3
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    
    contentView.addSubview(categoryLabel)
    categoryLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func configureUI(with model: MainNoticeType) {
    categoryLabel.text = model.tag
  }
}

extension CategoryCollectionViewCell {
  static func estimatedCellSize(_ targetSize: CGSize, model: MainNoticeType) -> CGSize {
    let cell = CategoryCollectionViewCell()
    cell.configureUI(with: model)
    return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
  }
}
