//
//  ChapelDayView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

final class ChapelDayView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 16)
    $0.text = "확정일수"
    $0.sizeToFit()
  }
  
  private let dayLabel = UILabel().then {
    $0.textColor = .hex4B81EE
    $0.font = .bold44
    $0.sizeToFit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, dayLabel].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(7)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    dayLabel.text = "\(model)일"
  }
}
