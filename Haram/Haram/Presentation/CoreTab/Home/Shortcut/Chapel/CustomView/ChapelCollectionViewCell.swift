//
//  ChapelCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct ChapelCollectionViewCellModel {
  let chapelResult: ChapelResultType
  let chapelDate: Date
  
  init(response: InquireChapelDetailResponse) {
    chapelResult = ChapelResultType.allCases.filter { $0.title == response.attendance }.first!
    chapelDate = DateformatterFactory.dateForYearMonthDayHourMinuteSecond.date(from: response.date) ?? Date()
  }
  
  init(chapelResult: ChapelResultType) {
    self.chapelResult = chapelResult
    chapelDate = Date()
  }
}

enum ChapelResultType: CaseIterable {
  case attendance
  case late
  case absence 
  
  var title: String {
    switch self {
    case .attendance:
      return "출석"
    case .late:
      return "지각"
    case .absence:
      return "결석"
    }
  }
  
  var imageName: String {
    switch self {
    case .attendance:
      return "smileYellow"
    case .late, .absence:
      return "sadYellow"
    }
  }
}

final class ChapelCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let chapelImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 22
    $0.contentMode = .scaleAspectFill
    $0.backgroundColor = .hexD9D9D9
  }
  
  private let chapelTitleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.textAlignment = .left
  }
  
  private let chapelSubTitleLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.textAlignment = .left
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
    chapelTitleLabel.text = nil
    chapelSubTitleLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [chapelImageView, chapelTitleLabel, chapelSubTitleLabel].forEach {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    
    chapelImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalToSuperview().inset(15)
    }
    
    chapelTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(chapelImageView.snp.trailing).offset(15)
      $0.trailing.equalToSuperview().inset(15)
      $0.bottom.equalTo(chapelImageView.snp.centerY)
    }
    
    chapelSubTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(chapelImageView.snp.trailing).offset(15)
      $0.trailing.equalToSuperview().inset(15)
      $0.top.equalTo(chapelImageView.snp.centerY)
      $0.bottom.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: ChapelCollectionViewCellModel) {
    chapelImageView.image = UIImage(named: model.chapelResult.imageName)
    chapelTitleLabel.text = model.chapelResult.title
    chapelSubTitleLabel.text = DateformatterFactory.dateForHaram.string(from: model.chapelDate)
  }
}
