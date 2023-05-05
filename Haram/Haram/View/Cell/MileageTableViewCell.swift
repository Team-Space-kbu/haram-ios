//
//  MileageTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/05.
//

import UIKit

import SnapKit
import Then

final class MileageTableViewCell: UITableViewCell {
  static let identifier = "MileageTableViewCell"
  
  private let mileageImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 22
    $0.layer.masksToBounds = true
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18)
    $0.text = "Lorem Ipsum"
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
    $0.text = "Lorem Ipsum"
  }
  
  private let mileageLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .hex545E6A
    $0.text = "200,000"
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [mileageImageView, mainLabel, subLabel, mileageLabel].forEach { addSubview($0) }
    mileageImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.leading.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(20)
    }
    
    mainLabel.snp.makeConstraints {
      $0.leading.equalTo(mileageImageView.snp.trailing).offset(15)
      $0.bottom.equalTo(mileageImageView.snp.centerY)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(mileageImageView.snp.centerY)
      $0.leading.equalTo(mainLabel)
    }
    
    mileageLabel.snp.makeConstraints {
      $0.leading.lessThanOrEqualTo(mainLabel.snp.trailing)
      $0.centerY.equalTo(mileageImageView)
      $0.trailing.equalToSuperview()
    }
  }
}
