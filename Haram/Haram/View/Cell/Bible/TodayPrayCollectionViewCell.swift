//
//  BibleCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

struct TodayPrayCollectionViewCellModel {
  let prayTitle: String
  let prayContent: String
}

final class TodayPrayCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "TodayPrayCollectionViewCell"
  
  private let prayTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex545E6A
  }
  
  private let prayContentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.numberOfLines = 0
//    $0.lineBreakMode = .
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 10
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.hex707070.cgColor
    
    [prayTitleLabel, prayContentLabel].forEach { contentView.addSubview($0) }
    prayTitleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(10)
    }
    
    prayContentLabel.snp.makeConstraints {
      $0.top.equalTo(prayTitleLabel.snp.bottom).offset(5)
      $0.leading.equalTo(prayTitleLabel)
      $0.trailing.bottom.lessThanOrEqualToSuperview().inset(10)
    }
  }
  
  func configureUI(with model: TodayPrayCollectionViewCellModel) {
    
    prayTitleLabel.text = model.prayTitle
    prayContentLabel.addLineSpacing(lineSpacing: 3, string: model.prayContent)
    
  }
}
