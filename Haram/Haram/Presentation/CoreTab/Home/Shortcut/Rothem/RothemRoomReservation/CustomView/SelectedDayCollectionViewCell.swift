//
//  SelectedDayCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct SelectedDayCollectionViewCellModel {
  let calendarSeq: Int
  let title: String
  let day: String
  let isAvailable: Bool
  var isSelected: Bool
  let times: [Time]?
  
  init(calendarResponse: CalendarResponse) {
    calendarSeq = calendarResponse.calendarSeq
    title = calendarResponse.day.text + "요일"
    day = calendarResponse.date
    isAvailable = calendarResponse.isAvailable
    times = calendarResponse.times
    isSelected = false
  }
}

final class SelectedDayCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let entireView = UIView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.clear.cgColor
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    dayLabel.text = nil
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    contentView.addSubview(entireView)
    [titleLabel, dayLabel].forEach { entireView.addSubview($0) }
    
    entireView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.directionalHorizontalEdges.equalToSuperview().inset(3)
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(3)
    }
  }
  
  private func updateIfNeeded() {
    entireView.backgroundColor = isSelected ? .hex79BD9A : .white
    entireView.layer.borderColor = isSelected ? UIColor.hex79BD9A.cgColor : UIColor.hex707070.cgColor
    titleLabel.textColor = isSelected ? .hexF2F3F5 : .black
    dayLabel.textColor = isSelected ? .hexF2F3F5 : .black
  }
  
  func configureUI(with model: SelectedDayCollectionViewCellModel) {
    titleLabel.text = model.title
    dayLabel.text = model.day
    
    guard model.isAvailable else {
      entireView.backgroundColor = .hex545E6A
      entireView.layer.borderColor = UIColor.hex545E6A.cgColor
      titleLabel.textColor = .white
      dayLabel.textColor = .white
      return
    }
    
    entireView.backgroundColor = model.isSelected ? .hex79BD9A : .white
    entireView.layer.borderColor = model.isSelected ? UIColor.hex79BD9A.cgColor : UIColor.hex707070.cgColor
    titleLabel.textColor = model.isSelected ? .hexF2F3F5 : .black
    dayLabel.textColor = model.isSelected ? .hexF2F3F5 : .black
  }
}
