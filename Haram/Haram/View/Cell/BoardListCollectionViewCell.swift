//
//  BoardListCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/07/30.
//

import UIKit

import SnapKit
import Then

struct BoardListCollectionViewCellModel {
  let title: String
  let subTitle: String
}

final class BoardListCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BoardListCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex1A1E27
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .hexF8F8F8
    
    [titleLabel, subLabel].forEach { contentView.addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(7)
      $0.leading.equalToSuperview().inset(11)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(3)
      $0.leading.equalTo(titleLabel)
    }
  }
  
  func configureUI(with model: BoardListCollectionViewCellModel) {
    titleLabel.text = model.title
    subLabel.text = model.subTitle
  }
}
