//
//  RerequestAlertView.swift
//  Haram
//
//  Created by 이건준 on 10/18/23.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class RerequestAlertView: UIView {
  private let alertLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.text = "이메일이 도착하지 않았나요?"
  }
  
  let reRequestButton = UIButton(configuration: .haramLabelButton(title: "재요청하기", forgroundColor: .hex2F80ED))
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [alertLabel, reRequestButton].forEach { addSubview($0) }
    alertLabel.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
    
    reRequestButton.snp.makeConstraints {
      $0.leading.equalTo(alertLabel.snp.trailing).offset(6)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
}
