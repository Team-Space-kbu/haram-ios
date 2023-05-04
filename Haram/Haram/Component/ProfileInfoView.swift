//
//  ProfileInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/04.
//

import UIKit

import SnapKit
import Then

final class ProfileInfoView: UIView {
  
  private let nameLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.sizeToFit()
    $0.text = "임성묵"
  }
  
  private let emailLabel = UILabel().then {
    $0.textColor = .lightGray
    $0.font = .systemFont(ofSize: 20, weight: .regular)
    $0.sizeToFit()
    $0.text = "Lorem ipsum@gmail.com"
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let moreLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.text = "더보기"
    $0.sizeToFit()
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicator"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [nameLabel, emailLabel, lineView, moreLabel, indicatorButton].forEach { addSubview($0) }
    nameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(13)
      $0.leading.equalToSuperview().inset(15)
    }
    
    emailLabel.snp.makeConstraints {
      $0.leading.equalTo(nameLabel)
      $0.top.equalTo(nameLabel.snp.bottom).offset(3)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalTo(emailLabel.snp.bottom).offset(16)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    moreLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(13)
      $0.leading.equalTo(emailLabel)
    }
    
    indicatorButton.snp.makeConstraints {
      $0.centerY.equalTo(moreLabel)
      $0.trailing.equalToSuperview().inset(16)
    }
  }
}
