//
//  SelectedTimeCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct SelectedTimeCollectionViewCellModel: Hashable {
  let timeSeq: Int
  let time: String
  let meridiem: Meridiem
  let isReserved: Bool
  var isTimeSelected: Bool
  
  init(time: Time) {
    self.timeSeq = time.timeSeq
    self.time = time.hour + ":" + time.minute
    self.meridiem = time.meridiem
    self.isReserved = time.isReserved
    self.isTimeSelected = false
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(timeSeq)
  }
  
  static func == (lhs: SelectedTimeCollectionViewCellModel, rhs: SelectedTimeCollectionViewCellModel) -> Bool {
    return lhs.timeSeq == rhs.timeSeq
  }
}

final class SelectedTimeCollectionViewCell: UICollectionViewCell, ReusableView {
  
  var isReserved: Bool = false {
    didSet {
      updateIfNeeded()
    }
  }
  
  var isTimeSelected: Bool = false {
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
    
    isSkeletonable = true
    skeletonCornerRadius = 10
    contentView.isSkeletonable = true
    
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 10
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.clear.cgColor
    
    contentView.addSubview(timeLabel)
    timeLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  private func updateIfNeeded() {
    if !isReserved {
      contentView.backgroundColor = isTimeSelected ? .hex79BD9A : .white
      contentView.layer.borderColor = isTimeSelected ? UIColor.hex79BD9A.cgColor : UIColor.hex707070.cgColor
      timeLabel.textColor = isTimeSelected ? .hexF2F3F5 : .black
    } else {
      contentView.backgroundColor = .hex545E6A
      timeLabel.textColor = .white
    }
  }
  
  func configureUI(with model: SelectedTimeCollectionViewCellModel) {
    timeLabel.text = model.time
    self.isTimeSelected = model.isTimeSelected
    self.isReserved = model.isReserved
    contentView.isUserInteractionEnabled = !model.isReserved
  }
  
  func setHighlighted(isHighlighted: Bool) {
    
    if isHighlighted {
      let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
      UIView.transition(with: self.contentView, duration: 0.1) {
        self.contentView.alpha = 0.5
        self.contentView.transform = pressedDownTransform
      }
    } else {
      UIView.transition(with: self.contentView, duration: 0.1) {
        self.contentView.alpha = 1
        self.contentView.transform = .identity
      }
    }
  }
}
