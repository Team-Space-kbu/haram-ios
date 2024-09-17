//
//  AlertInfoViewCell.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class AlertInfoViewCell: UICollectionViewCell, ReusableView {
  
  private lazy var mainView = UILabel().then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
    $0.textColor = .white
    $0.font = .bold12
    $0.textAlignment = .center
  }
  
  private lazy var alertTitleLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .hex545E6A
    $0.isSkeletonable = true
  }
  
  private lazy var alertDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.numberOfLines = 0
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    _ = [mainView, alertTitleLabel, alertDescriptionLabel].map { addSubview($0) }
    mainView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.size.equalTo(40)
    }
    
    alertTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mainView.snp.top).offset(4)
      $0.leading.equalTo(mainView.snp.trailing).offset(9)
    }
    
    alertDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(alertTitleLabel.snp.bottom)
      $0.leading.equalTo(alertTitleLabel)
      $0.trailing.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
}

// MARK: - Data Configuration
struct AlertInfoViewCellModel {
  let mainTitle: String
  let mainColor: UIColor
  let title: String
  let description: String
}

extension AlertInfoViewCell {
  func configureUI(with model: AlertInfoViewCellModel) {
    mainView.text = model.mainTitle
    mainView.backgroundColor = model.mainColor
    alertTitleLabel.text = model.title
    alertDescriptionLabel.text = model.description
  }
}
