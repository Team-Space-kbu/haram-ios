//
//  MileageTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import UIKit

import SnapKit
import Then

final class MileageTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "MileageTableHeaderView"
  
  private let totalMileageLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .systemFont(ofSize: 36)
    $0.text = "10218원"
  }
  
  private let reloadLabel = UILabel().then {
    $0.text = "새로고침"
    $0.font = .regular
    $0.font = .systemFont(ofSize: 20)
  }
  
  private let reloadButton = UIButton().then {
    $0.setImage(UIImage(named: "reloadGray"), for: .normal)
  }
  
  private let spendListLabel = UILabel().then {
    $0.text = "소비내역"
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [totalMileageLabel, reloadLabel, reloadButton, spendListLabel].forEach { addSubview($0) }
    totalMileageLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(69.97)
      $0.leading.equalToSuperview()
    }
    
    reloadLabel.snp.makeConstraints {
      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(14)
      $0.leading.equalTo(totalMileageLabel)
    }
    
    reloadButton.snp.makeConstraints {
      $0.size.equalTo(16)
      $0.centerY.equalTo(reloadLabel)
      $0.leading.equalTo(reloadLabel.snp.trailing).offset(4)
    }
    
    spendListLabel.snp.makeConstraints {
      $0.top.equalTo(reloadLabel.snp.bottom).offset(95)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(3)
    }
  }
}
