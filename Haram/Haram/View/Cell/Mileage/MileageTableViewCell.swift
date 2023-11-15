//
//  MileageTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/05.
//

import UIKit

import SnapKit
import Then

struct MileageTableViewCellModel {
  let mainText: String
  let subText: String
  let mileage: Int
}

final class MileageTableViewCell: UITableViewCell {
  static let identifier = "MileageTableViewCell"
  
  private let mileageImageView = UIImageView().then {
    $0.backgroundColor = .hexD9D9D9
    $0.layer.cornerRadius = 22
    $0.layer.masksToBounds = true
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold18
    $0.numberOfLines = 1
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular14
  }
  
  private let mileageLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex545E6A
    $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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
    mainLabel.text = nil
    subLabel.text = nil
    mileageLabel.text = nil
  }
  
  private func configureUI() {
    selectionStyle = .none
    [mileageImageView, mainLabel, subLabel, mileageLabel].forEach { addSubview($0) }
    mileageImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.top.leading.equalToSuperview()
    }
    
    mainLabel.snp.makeConstraints {
      $0.leading.equalTo(mileageImageView.snp.trailing).offset(15)
      $0.top.equalTo(mileageImageView.snp.top).offset(3)
    }
    
    subLabel.snp.makeConstraints {
      $0.bottom.equalTo(mileageImageView.snp.bottom).offset(-4)
      $0.leading.equalTo(mainLabel)
    }
    
    mileageLabel.snp.makeConstraints {
      $0.leading.greaterThanOrEqualTo(mainLabel.snp.trailing)
      $0.centerY.equalTo(mileageImageView)
      $0.trailing.equalToSuperview()
      $0.bottom.equalTo(mileageImageView)
    }
  }
  
  func configureUI(with model: MileageTableViewCellModel) {
    let mileage = model.mileage
    if mileage >= 0 {
      mileageLabel.textColor = .hex4B81EE
    }
    let formatter = NumberformatterFactory.decimal
    let decimalMileage = formatter.string(for: mileage) ?? "0"
    
    mainLabel.text = model.mainText
    subLabel.text = model.subText
    mileageLabel.text = decimalMileage
  }
}
