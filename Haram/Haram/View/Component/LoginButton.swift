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
    $0.spacing = 31
//    $0.distribution = .fill
  }
  
  private let loginButton = UIButton().then {
    $0.backgroundColor = .hex79BD9A
    $0.titleLabel?.font = .bold14
    $0.tintColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.setTitle("로그인", for: .normal)
  }
  
  private let findPasswordButton = UIButton().then {
    $0.setTitleColor(.label, for: .normal)
    $0.titleLabel?.font = .regular
    $0.titleLabel?.font = .systemFont(ofSize: 14)
    $0.setTitle("비밀번호를 잊으셨나요?", for: .normal)
    $0.titleLabel?.numberOfLines = 1
    $0.sizeToFit()
  }
  
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
    
    loginButton.snp.makeConstraints {
      $0.width.equalTo(148)
    }
    
    findPasswordButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(41)
    }
  
  }
}
