//
//  AffiliatedIntroduceView.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import SnapKit
import Then

struct AffiliatedIntroduceViewModel {
  let title: String
  let content: String
}

final class AffiliatedIntroduceView: UIView {
  
  private let introduceTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let introduceContentLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    _ = [introduceTitleLabel, introduceContentLabel].map { addSubview($0) }
    introduceTitleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(22)
    }
    
    introduceContentLabel.snp.makeConstraints {
      $0.top.equalTo(introduceTitleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: AffiliatedIntroduceViewModel) {
    introduceTitleLabel.text = model.title
    introduceContentLabel.addLineSpacing(lineSpacing: 2, string: model.content)
  }
}
