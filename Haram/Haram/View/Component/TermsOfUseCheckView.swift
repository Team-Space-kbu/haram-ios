//
//  TermsOfUseView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/02.
//

import UIKit

import SnapKit
import Then

final class TermsOfUseCheckView: UIView {
    
  // MARK: - UI Components
  
  private let checkButton = UIButton().then {
    $0.setImage(UIImage(named: Constants.checkImageName), for: .normal)
  }
  
  private let alertLabel = UILabel().then {
    $0.text = Constants.alertText
    $0.font = .regular14
    $0.textColor = .hex545E6A
  }
  
  private let termsLabel = PaddingLabel(withInsets: 4, 7, 6, 6).then {
    $0.backgroundColor = .hexF2F3F5
    $0.textColor = .hex545E6A
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.numberOfLines = 0
    $0.text = """
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita
kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
"""
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func configureUI() {
    [checkButton, alertLabel, termsLabel].forEach { addSubview($0) }
    checkButton.snp.makeConstraints {
      $0.size.equalTo(14.06)
      $0.leading.equalToSuperview()
    }
    
    alertLabel.snp.makeConstraints {
      $0.leading.equalTo(checkButton.snp.trailing).offset(10)
      $0.trailing.lessThanOrEqualToSuperview()
      $0.centerY.equalTo(checkButton)
    }
    
    termsLabel.snp.makeConstraints {
      $0.top.equalTo(checkButton.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  // MARK: - Constants
  
  enum Constants {
    static let alertText = "아래 약관에 모두 동의합니다."
    static let checkImageName = "markBlack"
  }
}
