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

struct AffiliatedTableViewCellModel {
  let id: Int
  let affiliatedImageURL: URL?
  let affiliatedTitle: String
  let affiliatedSubTitle: String
  
  init(response: InquireAffiliatedResponse) {
    id = response.id
    affiliatedImageURL = URL(string: response.imageString)
    affiliatedTitle = response.businessName
    affiliatedSubTitle = response.address
  }
}

final class AffiliatedTableViewCell: UITableViewCell, ReusableView {
  
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
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    selectionStyle = .none
    isSkeletonable = true
    contentView.isSkeletonable = true
    contentView.backgroundColor = .white
    
    contentView.addSubview(containerView)
    [affiliatedImageView, affiliatedTitleLabel, affiliatedSubTitleLabel].forEach { containerView.addSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(100)
    }
    
    affiliatedImageView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.size.equalTo(100)
    }
    
    affiliatedTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalTo(affiliatedImageView.snp.trailing).offset(12)
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
  
  func configureUI(with model: AffiliatedTableViewCellModel) {
    affiliatedImageView.kf.setImage(with: model.affiliatedImageURL)
    affiliatedTitleLabel.text = model.affiliatedTitle
    affiliatedSubTitleLabel.text = model.affiliatedSubTitle
  }
}
