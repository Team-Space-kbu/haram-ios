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
      $0.top.leading.equalToSuperview().inset(15)
    }
    
    prayContentLabel.snp.makeConstraints {
      $0.top.equalTo(prayTitleLabel.snp.bottom)
      $0.leading.equalTo(prayTitleLabel)
      $0.trailing.lessThanOrEqualToSuperview().inset(15)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: TodayPrayCollectionViewCellModel) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 8

    let attributedString = NSAttributedString(
      string: model.prayContent,
      attributes: [.paragraphStyle: paragraphStyle]
    )
    
    prayTitleLabel.text = model.prayTitle
    prayContentLabel.attributedText = attributedString
  }
}
