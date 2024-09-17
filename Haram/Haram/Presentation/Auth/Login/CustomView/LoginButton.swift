//
//  LoginButton.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class LoginButton: UIView {
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
  }
  
  let loginButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "로그인", contentInsets: .zero)
  }
  
  let findPasswordButton = UIButton(configuration: .haramLabelButton(title: "회원 정보를 잊으셨나요?"))
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerView)
    [loginButton, findPasswordButton].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [loginButton, findPasswordButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(48)
      }
    }
  }
}
