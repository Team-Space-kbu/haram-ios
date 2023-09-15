//
//  AffiliatedCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct AffiliatedCollectionViewCellModel: Equatable {
  let affiliatedX: Double
  let affiliatedY: Double
  let affiliatedImageURL: URL?
  let affiliatedTitle: String
  let affiliatedSubTitle: String
  
  init(response: InquireAffiliatedResponse) {
    affiliatedX = Double(response.xCoordinate) ?? 0
    affiliatedY = Double(response.yCoordinate) ?? 0
    affiliatedImageURL = response.affiliatedImageURL
    affiliatedTitle = response.affiliatedName
    affiliatedSubTitle = response.description
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.affiliatedX == rhs.affiliatedX && lhs.affiliatedY == rhs.affiliatedY
  }
}

final class AffiliatedCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "AffiliatedCollectionViewCell"
  
  private let affiliatedImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
  }
  
  private let affiliatedTitleLabel = UILabel()
  
  private let affiliatedSubTitleLabel = UILabel().then {
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
    contentView.backgroundColor = .white
    contentView.layer.shadowRadius = 1
    contentView.layer.shadowOffset = CGSize(width: 10, height: 10)
    contentView.layer.shadowOpacity = 1
    contentView.layer.shadowColor = UIColor.black.cgColor
    
    [affiliatedImageView, affiliatedTitleLabel, affiliatedSubTitleLabel].forEach { contentView.addSubview($0) }
    affiliatedImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(107)
    }
    
    affiliatedTitleLabel.snp.makeConstraints {
      $0.top.equalTo(affiliatedImageView.snp.bottom).offset(11)
      $0.leading.equalToSuperview().inset(10)
      $0.trailing.lessThanOrEqualToSuperview().inset(10)
    }
    
    affiliatedSubTitleLabel.snp.makeConstraints {
      $0.top.equalTo(affiliatedTitleLabel.snp.bottom).offset(4)
      $0.leading.equalToSuperview().inset(10)
      $0.bottom.trailing.lessThanOrEqualToSuperview().inset(10)
    }
  }
  
  func configureUI(with model: AffiliatedCollectionViewCellModel) {
    affiliatedImageView.kf.setImage(with: model.affiliatedImageURL)
    affiliatedTitleLabel.text = model.affiliatedTitle
    affiliatedSubTitleLabel.text = model.affiliatedSubTitle
  }
}
