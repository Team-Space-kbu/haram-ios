//
//  MileageHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

final class MileageHeaderView: UIView {
  
  private let totalMileageLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold36
    $0.text = "10218원"
  }
  
  private let reloadLabel = UILabel().then {
    $0.text = "새로고침"
    $0.font = .regular20
  }
  
  private let reloadButton = UIButton().then {
    $0.setImage(UIImage(named: "reloadGray"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [totalMileageLabel, reloadLabel, reloadButton].forEach { addSubview($0) }
    totalMileageLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    reloadLabel.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(15)
    }
    
    reloadButton.snp.makeConstraints {
      $0.leading.equalTo(reloadLabel.snp.trailing).offset(8)
      $0.centerY.equalTo(reloadLabel)
      $0.size.equalTo(16)
    }
  }
}
