//
//  MoreViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

final class MoreViewController: BaseViewController {
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 19
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private let moreLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 26, weight: .bold)
    $0.text = "더보기"
  }
  
  private let profileInfoView = ProfileInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.backgroundColor = .hexF8F8F8
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(contentStackView)
    [moreLabel, profileInfoView].forEach { contentStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    contentStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    profileInfoView.snp.makeConstraints {
      $0.height.equalTo(131)
    }
    
    contentStackView.setCustomSpacing(67, after: moreLabel)
  }
}
