//
//  MileageTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import UIKit

import RxSwift
import SkeletonView
import SnapKit
import Then

struct MileageTableHeaderViewModel {
  let totalMileage: Int
}

final class MileageTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "MileageTableHeaderView"
  private var disposeBag = DisposeBag()
  
  private let totalMileageLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold36
    $0.isSkeletonable = true
    $0.text = "200,000원"
  }
  
  private let rocketImageView = UIImageView(image: UIImage(resource: .rocketBlue)).then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 18
    $0.layer.masksToBounds = true
  }
  
  private let mileageInfoTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex545E6A
  }
  
  private let mileageInfoSubTitleLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
  }
  
  private let spendListLabel = UILabel().then {
    $0.text = "소비내역"
    $0.textColor = .black
    $0.font = .bold14
    $0.isSkeletonable = true
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    totalMileageLabel.text = nil
    self.disposeBag = DisposeBag()
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [totalMileageLabel, spendListLabel, rocketImageView, mileageInfoTitleLabel, mileageInfoSubTitleLabel].forEach { contentView.addSubview($0) }
    totalMileageLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(69.97)
      $0.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    rocketImageView.snp.makeConstraints {
      $0.size.equalTo(36)
      $0.leading.equalToSuperview()
      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(10)
    }
    
    mileageInfoTitleLabel.snp.makeConstraints {
      $0.top.equalTo(rocketImageView)
      $0.leading.equalTo(rocketImageView.snp.trailing).offset(10)
    }
    
    mileageInfoSubTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mileageInfoTitleLabel.snp.bottom)
      $0.leading.equalTo(mileageInfoTitleLabel)
      $0.bottom.equalTo(rocketImageView)
    }
      
    spendListLabel.snp.makeConstraints {
//      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(135)
      $0.top.greaterThanOrEqualTo(rocketImageView.snp.bottom)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(15)
    }
    
    mileageInfoTitleLabel.text = "마일리지반영"
    mileageInfoSubTitleLabel.text = "마일리지정보가반영되는데시간이오래걸립니다."
  }
  
  func configureUI(with model: MileageTableHeaderViewModel) {
    let formatter = NumberformatterFactory.decimal
    let decimalTotalMileage = formatter.string(for: model.totalMileage) ?? "0"
    totalMileageLabel.text = "\(decimalTotalMileage)원"
  }
}
