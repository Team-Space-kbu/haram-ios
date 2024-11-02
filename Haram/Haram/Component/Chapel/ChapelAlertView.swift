//
//  ChapelAlertView.swift
//  Haram
//
//  Created by 이건준 on 9/23/24.
//

import UIKit

import SnapKit
import Then

final class ChapelAlertView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.text = "관련정보"
    $0.textColor = .black
    $0.font = .bold18
  }
  
  private let containerView = UIStackView().then {
    $0.spacing = 15
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private let infoView = IntranetAlertView(type: .info)
  private let inquiryView = IntranetAlertView(type: .inquiry)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [titleLabel, infoView, inquiryView].forEach { containerView.addArrangedSubview($0) }
    
    infoView.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    inquiryView.snp.makeConstraints {
      $0.height.equalTo(40)
    }
  }
}
