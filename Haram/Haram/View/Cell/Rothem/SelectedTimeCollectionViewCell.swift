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
  let timeSeq: Int
  let time: String
  let meridiem: Meridiem
  let isReserved: Bool
  
  init(time: Time) {
    self.timeSeq = time.timeSeq
    self.time = time.hour + ":" + time.minute
    self.meridiem = time.meridiem
    self.isReserved = time.isReserved
  }
}

final class SelectedTimeCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedTimeCollectionViewCell"
  
  override var isSelected: Bool {
    didSet {
      updateIfNeeded()
    }
  }
  
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
  
  private func updateIfNeeded() {
    contentView.backgroundColor = isSelected ? .hex79BD9A : .white
    contentView.layer.borderColor = isSelected ? UIColor.hex79BD9A.cgColor : UIColor.hex707070.cgColor
    timeLabel.textColor = isSelected ? .hexF2F3F5 : .black
  }
  
  func configureUI(with model: SelectedTimeCollectionViewCellModel) {
    timeLabel.text = model.time
    contentView.isUserInteractionEnabled = !model.isReserved
    if model.isReserved {
      contentView.backgroundColor = .lightGray
    }
  }
}
