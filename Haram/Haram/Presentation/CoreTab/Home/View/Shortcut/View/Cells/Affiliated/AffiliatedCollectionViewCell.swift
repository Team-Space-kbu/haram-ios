//
//  AffiliatedCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct AffiliatedCollectionViewCellModel {
  let id: Int
  let isLast: Bool
  let affiliatedImageURL: URL?
  let affiliatedTitle: String
  let affiliatedSubTitle: String
  
  init(response: InquireAffiliatedResponse, isLast: Bool) {
    self.isLast = isLast
    id = response.id
    affiliatedImageURL = URL(string: response.imageString)
    affiliatedTitle = response.businessName
    affiliatedSubTitle = response.address
  }
}

final class AffiliatedCollectionViewCell: UICollectionViewCell, ReusableView {
  
  let containerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let affiliatedImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.isSkeletonable = true
  }
  
  private let affiliatedTitleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .hex1A1E27
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let affiliatedSubTitleLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .regular15
    $0.textColor = .hex1A1E27
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 2
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
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
    affiliatedImageView.image = nil
    affiliatedTitleLabel.text = nil
    affiliatedSubTitleLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    contentView.backgroundColor = .white
    
    contentView.addSubview(containerView)
    [affiliatedImageView, affiliatedTitleLabel, affiliatedSubTitleLabel].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(94)
    }
    
    affiliatedImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.size.equalTo(94)
    }
    
    affiliatedTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalTo(affiliatedImageView.snp.trailing).offset(23)
      $0.trailing.equalToSuperview()
      $0.height.equalTo(24)
    }
    
    affiliatedSubTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(affiliatedTitleLabel.snp.leading)
      $0.top.equalTo(affiliatedTitleLabel.snp.bottom).offset(4)
      $0.trailing.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: AffiliatedCollectionViewCellModel) {
    
    if model.isLast {
      lineView.removeFromSuperview()
    } else {
      contentView.addSubview(lineView)
      lineView.snp.makeConstraints {
        $0.height.equalTo(1)
        $0.directionalHorizontalEdges.bottom.equalToSuperview()
      }
    }
    
    affiliatedImageView.kf.setImage(with: model.affiliatedImageURL)
    affiliatedTitleLabel.text = model.affiliatedTitle
    affiliatedSubTitleLabel.text = model.affiliatedSubTitle
  }
}
