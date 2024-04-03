//
//  HomeNoticeView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/09.
//

import UIKit

import SnapKit
import Then

struct HomeNoticeViewModel {
  let title: String
  let content: String
  
  init(subNotice: SubNotice) {
    title = subNotice.title
    content = subNotice.content
  }
}

final class HomeNoticeView: UIView {
  
  let button = UIButton()
  
  private let noticeImageView = UIImageView(image: UIImage(resource: .faceGray)).then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let noticeLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular16
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
    
    [noticeImageView, noticeLabel, button].forEach { addSubview($0) }
    noticeImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(11.39)
      $0.directionalVerticalEdges.equalToSuperview().inset(9)
      $0.width.equalTo(18.59)
    }
    
    noticeLabel.snp.makeConstraints {
      $0.leading.equalTo(noticeImageView.snp.trailing).offset(10.02)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomeNoticeViewModel) {
    noticeLabel.text = model.title
  }
}
