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

struct TodayBibleWordCollectionViewCellModel {
  let todayBibleWord: String
  let todayBibleBookName: String
}

final class TodayBibleWordCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let todayBibleWordLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.skeletonTextNumberOfLines = 2
    $0.isSkeletonable = true
  }
  
  private let todayBibleBookLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.skeletonTextNumberOfLines = 1
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
    _ = [todayBibleWordLabel, todayBibleBookLabel].map { contentView.addSubview($0) }
    
    todayBibleWordLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    todayBibleBookLabel.snp.makeConstraints {
      $0.top.equalTo(todayBibleWordLabel.snp.bottom).offset(18)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: TodayBibleWordCollectionViewCellModel) {
    todayBibleWordLabel.addLineSpacing(lineSpacing: 3, string: model.todayBibleWord)
    todayBibleBookLabel.text = model.todayBibleBookName
  }
}
