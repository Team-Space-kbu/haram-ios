//
//  LoginButton.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol LoginButtonDelegate: AnyObject {
  func didTappedLoginButton()
  func didTappedFindPasswordButton()
}

final class LoginButton: UIView {
  
  private let disposeBag = DisposeBag()
  weak var delegate: LoginButtonDelegate?
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }
  
  private let loginButton = UIButton(configuration: .haramFilledButton(title: "로그인", contentInsets: .zero))
  
  private let findPasswordButton = UIButton(configuration: .plain().with {
    $0.baseForegroundColor = .black
    $0.baseBackgroundColor = .clear
    $0.font = .regular14
    $0.title = "비밀번호를 잊으셨나요?"
    $0.contentInsets = .zero
    $0.titleAlignment = .leading
  })
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    loginButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedLoginButton()
      }
      .disposed(by: disposeBag)
    
    findPasswordButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedFindPasswordButton()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    addSubview(containerView)
    [loginButton, findPasswordButton].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}
