//
//  RegisterViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class RegisterViewController: BaseViewController {
  
  private let viewModel: RegisterViewModelType
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 25
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 66, left: 15, bottom: 49, right: 15)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "회원가입✏️"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "사용하실 계정 정보를 작성해주세요\n입력된 정보를 암호화 처리되어 사용자만 볼 수 있습니다."
    $0.textColor = .hex545E6A
    $0.numberOfLines = 0
  }
  
  private let idTextField = RegisterTextField(
    title: Constants.id.title,
    placeholder: Constants.id.placeholder
  )
  
  private let pwdTextField = RegisterTextField(
    title: Constants.password.title,
    placeholder: Constants.password.placeholder
  )
  
  private let repwdTextField = RegisterTextField(
    title: Constants.repassword.title,
    placeholder: Constants.repassword.placeholder,
    options: [.errorLabel]
  )
  
  private let nicknameTextField = RegisterTextField(
    title: Constants.nickname.title,
    placeholder: Constants.nickname.placeholder
  )
  
  private let emailTextField = RegisterTextField(
    title: Constants.schoolEmail.title,
    placeholder: Constants.schoolEmail.placeholder,
    options: [.defaultEmail]
  )
  
  private let checkEmailTextField = RegisterTextField(
    title: Constants.checkEmail.title,
    placeholder: Constants.checkEmail.placeholder,
    options: [.addButton]
  )
  
  private let registerButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "회원가입")
  }
  
  init(viewModel: RegisterViewModelType = RegisterViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
    [idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField, checkEmailTextField].forEach { $0.textField.delegate = self }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)

    [titleLabel, alertLabel, idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField, checkEmailTextField, registerButton].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    stackView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    stackView.setCustomSpacing(7, after: titleLabel)
    
    registerButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    [idTextField, pwdTextField, nicknameTextField, emailTextField, checkEmailTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(74)
      }
    }
    
    repwdTextField.snp.makeConstraints {
      $0.height.equalTo(84 + 15)
    }
    
    stackView.setCustomSpacing(10, after: repwdTextField)
  }
  
  override func bind() {
    super.bind()
    idTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.id.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, ID in
        owner.viewModel.registerID.onNext(ID)
      }
      .disposed(by: disposeBag)
    
    pwdTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.password.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, PWD in
        owner.viewModel.registerPWD.onNext(PWD)
      }
      .disposed(by: disposeBag)
    
    repwdTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.repassword.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, rePWD in
        owner.viewModel.registerRePWD.onNext(rePWD)
      }
      .disposed(by: disposeBag)
    
    nicknameTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.nickname.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, nickname in
        owner.viewModel.registerNickname.onNext(nickname)
      }
      .disposed(by: disposeBag)
    
    emailTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.schoolEmail.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, email in
        owner.viewModel.registerEmail.onNext(email)
      }
      .disposed(by: disposeBag)
    
    checkEmailTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.checkEmail.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, authCode in
        owner.viewModel.registerAuthCode.onNext(authCode)
      }
      .disposed(by: disposeBag)
    
    
    registerButton.rx.tap
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, _ in
        owner.viewModel.tappedRegisterButton.onNext(())
      }
      .disposed(by: disposeBag)
    
    viewModel.checkPasswordIsEqualMessage
      .emit(with: self) { owner, message in
        owner.repwdTextField.setError(description: message)
      }
      .disposed(by: disposeBag)
    
//    viewModel.isRegisterButtonEnabled
//      .drive(registerButton.rx.isEnabled)
//      .disposed(by: disposeBag)
  }
}

extension RegisterViewController {
  enum Constants {
    case id
    case password
    case repassword
    case nickname
    case schoolEmail
    case checkEmail
    
    var title: String {
      switch self {
      case .id:
        return "아이디"
      case .password:
        return "비밀번호"
      case .repassword:
        return "비밀번호 확인"
      case .checkEmail:
        return "이메일 확인"
      case .schoolEmail:
        return "학교 이메일"
      case .nickname:
        return "닉네임"
      }
    }
    
    var placeholder: String {
      switch self {
      case .id:
        return "ID"
      case .password, .repassword:
        return "Password"
      case .checkEmail:
        return "확인코드"
      case .schoolEmail:
        return "Email"
      case .nickname:
        return "Nickname"
      }
    }
  }
}

extension RegisterViewController: RegisterTextFieldDelegate {
  func didTappedButton() {
    print("확인코드발송 선택")
    view.endEditing(true)
  }
  
  func didTappedReturnKey() {
    print("리턴 선택")
    view.endEditing(true)
  }
}

extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == idTextField {
      idTextField.resignFirstResponder()
      pwdTextField.becomeFirstResponder()
    } else if textField == pwdTextField {
      pwdTextField.resignFirstResponder()
      repwdTextField.becomeFirstResponder()
    } else if textField == repwdTextField {
      repwdTextField.resignFirstResponder()
      nicknameTextField.becomeFirstResponder()
    } else if textField == nicknameTextField {
      nicknameTextField.resignFirstResponder()
      emailTextField.becomeFirstResponder()
    } else if textField == emailTextField {
      emailTextField.resignFirstResponder()
      checkEmailTextField.becomeFirstResponder()
    } else if textField == checkEmailTextField {
      checkEmailTextField.resignFirstResponder()
      view.endEditing(true)
    }
    return true
  }
}
