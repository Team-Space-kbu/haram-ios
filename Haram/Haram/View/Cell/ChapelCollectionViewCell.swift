//
//  ChapelCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

import SnapKit
import Then

struct ChapelCollectionViewCellModel {
  let title: String
  let subTitle: String
  
  init(response: InquireChapelListResponse) {
    title = response.attendanceDays
    subTitle = response.attendance
  }
}

final class ChapelCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "ChapelCollectionViewCell"
  
  private let chapelImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 22
    $0.contentMode = .scaleAspectFill
    $0.backgroundColor = .gray
  }
  
  private let chapelTitleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.sizeToFit()
    $0.text = "Lorem ipsum"
  }
  
  private let chapelSubTitleLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.text = "Lorem ipsum"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .white
    [chapelImageView, chapelTitleLabel, chapelSubTitleLabel].forEach { contentView.addSubview($0) }
    
    chapelImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalToSuperview().inset(15)
    }
    
    chapelTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(chapelImageView.snp.trailing).offset(15)
      $0.bottom.equalTo(chapelImageView.snp.centerY)
    }
    
    chapelSubTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(chapelImageView.snp.trailing).offset(15)
      $0.top.equalTo(chapelImageView.snp.centerY)
      $0.bottom.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: ChapelCollectionViewCellModel) {
    chapelTitleLabel.text = model.title
    chapelSubTitleLabel.text = model.subTitle
  }
}
