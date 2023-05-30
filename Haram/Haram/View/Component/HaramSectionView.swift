//
//  HaramSectionView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

final class HaramSectionView: UIView {
  
  private let verticalStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 23
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "하람"
    $0.font = .bold
    $0.textColor = .black
  }
  
  private let homeNoticeView = HomeNoticeView()
  
  private let homeAdvertisementView = HomeAdvertisementView().then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.backgroundColor = .hexA8DBA8
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(verticalStackView)
    verticalStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [homeNoticeView, homeAdvertisementView].forEach { verticalStackView.addArrangedSubview($0) }
    homeNoticeView.snp.makeConstraints {
      $0.height.equalTo(35)
    }
    
    homeAdvertisementView.snp.makeConstraints {
      $0.height.equalTo(142)
    }
    
    verticalStackView.setCustomSpacing(20, after: homeNoticeView)
  }
}
