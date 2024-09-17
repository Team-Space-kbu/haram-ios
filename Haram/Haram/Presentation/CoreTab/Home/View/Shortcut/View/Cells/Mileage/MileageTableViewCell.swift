//
//  MileageTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/05.
//

import UIKit

import SkeletonView
import SnapKit
import Then

struct MileageTableViewCellModel {
  let mainText: String
  let date: Date
  let mileage: Int
  let imageSource: ImageResource
}

final class MileageTableViewCell: UITableViewCell, ReusableView {
  
  private let mileageImageView = UIImageView().then {
    $0.backgroundColor = .hexD9D9D9
    $0.layer.cornerRadius = 22
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold18
    $0.numberOfLines = 1
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.isSkeletonable = true
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular14
    $0.isSkeletonable = true
  }
  
  private let mileageLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex545E6A
    $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    $0.isSkeletonable = true
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
    
    /// Set SkeletonView
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    /// Set Styles
    selectionStyle = .none
    
    
    /// Set Layout
    _ = [mileageImageView, mainLabel, subLabel, mileageLabel].map { contentView.addSubview($0) }
    
    /// Set Constraints
    mileageImageView.snp.makeConstraints {
      $0.size.equalTo(44)
      $0.top.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(20)
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
      $0.leading.greaterThanOrEqualTo(mainLabel.snp.trailing).offset(15)
      $0.centerY.equalTo(mileageImageView)
      $0.trailing.equalToSuperview()
      $0.bottom.equalTo(mileageImageView)
    }
  }
  
  func configureUI(with model: MileageTableViewCellModel) {
    let mileage = model.mileage
    let mainText = model.mainText
    
    mileageLabel.textColor = mileage >= 0 ? .hex4B81EE : .hex545E6A
    
    let formatter = NumberformatterFactory.decimal
    let decimalMileage = formatter.string(for: mileage) ?? "0"
    
    mainLabel.text = mainText
    subLabel.text = DateformatterFactory.dateWithHypen.string(from: model.date)
    mileageLabel.text = decimalMileage
    mileageImageView.image = UIImage(resource: model.imageSource)
  }
}
