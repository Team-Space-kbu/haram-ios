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
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(systemName: "face.smiling")
  }
  
  private let noticeLabel = UILabel().then {
    $0.textColor = .white
    $0.text = "알림 라벨입니다"
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .lightGray
    
    [noticeImageView, noticeLabel].forEach { addSubview($0) }
    noticeImageView.snp.makeConstraints {
      $0.directionalVerticalEdges.leading.equalToSuperview()
      $0.width.equalTo(35)
    }
    
    noticeLabel.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
}
