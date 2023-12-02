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
  private let disposeBag = DisposeBag()
  
  private let totalMileageLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold36
    $0.isSkeletonable = true
    $0.text = "200,000원"
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
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [totalMileageLabel, spendListLabel].forEach { contentView.addSubview($0) }
    totalMileageLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(69.97)
      $0.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
      
    spendListLabel.snp.makeConstraints {
      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(135)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(15)
    }
  }
  
  func configureUI(with model: MileageTableHeaderViewModel) {
    let formatter = NumberformatterFactory.decimal
    let decimalTotalMileage = formatter.string(for: model.totalMileage) ?? "0"
    totalMileageLabel.text = "\(decimalTotalMileage)원"
  }
}
