//
//  SelectedTimeCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

struct SelectedTimeCollectionViewCellModel {
  let time: String
}

final class SelectedTimeCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedTimeCollectionViewCell"
  
  private let timeLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .hex1A1E27
    $0.textAlignment = .center
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
    
    contentView.addSubview(timeLabel)
    timeLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: SelectedTimeCollectionViewCellModel) {
    timeLabel.text = model.time
  }
}
