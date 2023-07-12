//
//  LoginAlertView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then
final class LoginAlertView: UIView {
  
  private let alertLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular
    $0.font = .systemFont(ofSize: 13)
    $0.text = "아직 회원가입하지 않았나요?"
  }
  
  private let alertButton = UIButton().then {
    $0.setTitleColor(.hex3B8686, for: .normal)
    $0.setTitle("회원가입", for: .normal)
    $0.titleLabel?.font = .bold
    $0.titleLabel?.font = .systemFont(ofSize: 13)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [alertLabel, alertButton].forEach { addSubview($0) }
    alertLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(90 - 22)
      $0.directionalVerticalEdges.equalToSuperview()
    }
    
    alertButton.snp.makeConstraints {
      $0.leading.equalTo(alertLabel.snp.trailing).offset(12)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.equalToSuperview().inset(90 - 22)
    }
  }
}
