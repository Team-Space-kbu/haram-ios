//
//  SelectedDayCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

struct SelectedDayCollectionViewCellModel {
  let calendarSeq: Int
  let title: String
  let day: String
  let isAvailable: Bool
  
  init(calendarResponse: CalendarResponse) {
    calendarSeq = calendarResponse.calendarSeq
    title = calendarResponse.day.text + "요일"
    day = calendarResponse.date
    isAvailable = calendarResponse.isAvailable
  }
}

final class SelectedDayCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "SelectedDayCollectionViewCell"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let dayLabel = UILabel().then {
    $0.font = .bold24
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  override var isSelected: Bool {
    didSet {
      updateIfNeeded()
    }
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

    [titleLabel, dayLabel].forEach { contentView.addSubview($0) }
    
    titleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  private func updateIfNeeded() {
    contentView.backgroundColor = isSelected ? .hex79BD9A : .white
    contentView.layer.borderColor = isSelected ? UIColor.hex79BD9A.cgColor : UIColor.hex707070.cgColor
    titleLabel.textColor = isSelected ? .hexF2F3F5 : .black
    dayLabel.textColor = isSelected ? .hexF2F3F5 : .black
  }
  
  func configureUI(with model: SelectedDayCollectionViewCellModel) {
    titleLabel.text = model.title
    dayLabel.text = model.day
    self.isUserInteractionEnabled = model.isAvailable
    if !model.isAvailable {
      contentView.backgroundColor = .lightGray
    }
//    self.isDaySelected = model.isSelected
  }
  
}
