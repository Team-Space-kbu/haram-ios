//
//  AffiliatedBenefitView.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import SnapKit
import Then

struct AffiliatedBenefitViewModel {
  let title: String
  let content: String
}

final class AffiliatedBenefitView: UIView {
  
  private let benefitTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  private let benefitContentLabel = PaddingLabel(withInsets: 8, 8, 8, 8).then {
    $0.font = .bold14
    $0.textColor = .hex9F9FA4
    $0.backgroundColor = .hexF2F3F5
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.skeletonCornerRadius = 10
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
    _ = [benefitTitleLabel, benefitContentLabel].map { addSubview($0) }
    benefitTitleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    benefitContentLabel.snp.makeConstraints {
      $0.top.equalTo(benefitTitleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: AffiliatedBenefitViewModel) {
    benefitTitleLabel.text = model.title
    benefitContentLabel.addLineSpacing(lineSpacing: 2, string: model.content)
  }
}
