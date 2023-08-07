//
//  NoticeCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/28.
//

import UIKit

import SnapKit
import Then

struct NoticeCollectionViewCellModel {
  let title: String
  let description: String
}

final class NoticeCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "NoticeCollectionViewCell"
  
  private let mainLabel = UILabel().then {
    $0.font = .bold
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .hex1A1E27
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .hex1A1E27
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "indicator"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .hexF8F8F8
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    
    [mainLabel, subLabel, indicatorButton].forEach { contentView.addSubview($0) }
    
    mainLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(12)
      $0.trailing.lessThanOrEqualToSuperview().inset(12)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(mainLabel.snp.bottom).offset(3)
      $0.leading.equalTo(mainLabel)
      $0.bottom.trailing.lessThanOrEqualToSuperview()
    }
    
    indicatorButton.snp.makeConstraints {
      $0.width.equalTo(6)
      $0.height.equalTo(12)
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(14)
    }
  }
  
  func configureUI(with model: NoticeCollectionViewCellModel) {
    mainLabel.text = model.title
    subLabel.text = model.description
  }
}
