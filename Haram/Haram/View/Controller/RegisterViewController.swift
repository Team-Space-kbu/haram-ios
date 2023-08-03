//
//  RegisterViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

final class RegisterViewController: BaseViewController {
  
  private let viewModel: RegisterViewModelType
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 25
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "회원가입✏️"
    $0.textColor = .black
    $0.font = .bold
    $0.font = .systemFont(ofSize: 24)
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "사용하실 계정 정보를 작성해주세요\n입력된 정보를 암호화 처리되어 사용자만 볼 수 있습니다."
    $0.textColor = .hex545E6A
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
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(stackView)
    view.addSubview(registerButton)
    [titleLabel, alertLabel, idTextField, pwdTextField, repwdTextField, checkEmailTextField].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    stackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    registerButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(65 - 16)
      $0.height.equalTo(48)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    [idTextField, pwdTextField, repwdTextField, checkEmailTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(74)
      }
    }
  }
  
  override func bind() {
    super.bind()
    idTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.id.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, ID in
        print("아이디 \(ID)")
        owner.viewModel.registerID.onNext(ID)
      }
      .disposed(by: disposeBag)
    
    pwdTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.password.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, PWD in
        print("비밀번호 \(PWD)")
        owner.viewModel.registerPWD.onNext(PWD)
      }
      .disposed(by: disposeBag)
    
    repwdTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.repassword.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, rePWD in
        print("비밀번호 확인 \(rePWD)")
        owner.viewModel.registerRePWD.onNext(rePWD)
      }
      .disposed(by: disposeBag)
    
    checkEmailTextField.rx.text
      .orEmpty
      .filter { $0 != Constants.checkEmail.placeholder }
      .distinctUntilChanged()
      .skip(1)
      .subscribe(with: self) { owner, email in
        print("이메일 \(email)")
        owner.viewModel.registerEmail.onNext(email)
      }
      .disposed(by: disposeBag)
    
    registerButton.rx.tap
      .subscribe(with: self) { owner, _ in
        print("회원가입버튼 탭")
      }
      .disposed(by: disposeBag)
    
    viewModel.isRegisterButtonEnabled
      .drive(registerButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

extension RegisterViewController {
  enum Constants {
    case id
    case password
    case repassword
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
