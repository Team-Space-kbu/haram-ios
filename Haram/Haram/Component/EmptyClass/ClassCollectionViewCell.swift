//
//  ClassCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class ClassCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private lazy var classLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .bold18
    $0.textAlignment = .left
    contentView.addSubview($0)
  }
  
  private lazy var indicatorView = UIImageView().then {
    $0.image = UIImage(resource: .rightIndicator).withTintColor(.hex545E6A)
    $0.contentMode = .scaleAspectFit
    contentView.addSubview($0)
    $0.snp.makeConstraints { $0.size.equalTo(16) }
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
    contentView.backgroundColor = .hexF2F3F5
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 8
    
    classLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(13)
      $0.centerY.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.leading.equalTo(classLabel.snp.trailing)
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(13)
    }
  }
}

// MARK: - Data Configuration
extension ClassCollectionViewCell {
  func configureUI(title: String) {
    classLabel.text = title
  }
}
