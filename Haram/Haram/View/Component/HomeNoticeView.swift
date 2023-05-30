//
//  HomeNoticeView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

final class HomeNoticeView: UIView {
  
  private let noticeImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: "faceGray")
  }
  
  private let noticeLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.text = "알림 라벨입니다"
    $0.font = .systemFont(ofSize: 16, weight: .regular)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .hexF2F3F5
    layer.cornerRadius = 10
    layer.masksToBounds = true
    
    [noticeImageView, noticeLabel].forEach { addSubview($0) }
    noticeImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(11.39)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(18.59)
      $0.height.equalTo(16.98)
    }
    
    noticeLabel.snp.makeConstraints {
      $0.leading.equalTo(noticeImageView.snp.trailing).offset(10.02)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
}
