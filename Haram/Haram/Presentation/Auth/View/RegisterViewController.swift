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
import RxCocoa

final class RegisterViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: RegisterViewModelType
  
  // MARK: - UI Components
  
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
  
  private let idTextField = HaramTextField(
    title: Constants.id.title,
    placeholder: Constants.id.placeholder,
    options: [.errorLabel]
  )
  
  private let pwdTextField = HaramTextField(
    title: Constants.password.title,
    placeholder: Constants.password.placeholder,
    options: [.errorLabel]
  )
  
  private let repwdTextField = HaramTextField(
    title: Constants.repassword.title,
    placeholder: Constants.repassword.placeholder,
    options: [.errorLabel]
  )
  
  private let nicknameTextField = HaramTextField(
    title: Constants.nickname.title,
    placeholder: Constants.nickname.placeholder,
    options: [.errorLabel]
  )
  
  private let emailTextField = HaramTextField(
    title: Constants.schoolEmail.title,
    placeholder: Constants.schoolEmail.placeholder,
    options: [.defaultEmail, .errorLabel]
  )
  
  private lazy var checkEmailTextField = HaramTextField(
    title: Constants.checkEmail.title,
    placeholder: Constants.checkEmail.placeholder,
    options: [.addButton, .errorLabel]
  ).then {
    $0.delegate = self
    $0.textField.isSecureTextEntry = true
  }
  
  private let registerButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "회원가입")
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  private let tapGesture = UITapGestureRecognizer(target: RegisterViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: RegisterViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: RegisterViewModelType = RegisterViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
    view.addGestureRecognizer(tapGesture)
    [idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField, checkEmailTextField].forEach { $0.textField.delegate = self }
    
    view.addGestureRecognizer(tapGesture)
    view.addGestureRecognizer(panGesture)
    panGesture.delegate = self
    
    registerNotifications()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [scrollView, indicatorView].map { view.addSubview($0) }
    scrollView.addSubview(stackView)

    [titleLabel, alertLabel, idTextField, nicknameTextField, pwdTextField, repwdTextField, emailTextField, checkEmailTextField, registerButton].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
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
    
    [idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField, checkEmailTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.greaterThanOrEqualTo(46 + 18 + 10)
      }
    }
  }
  
  override func bind() {
    super.bind()
    
    idTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let id = owner.idTextField.textField.text else { return }
        owner.viewModel.checkUserIDIsValid(id: id)
      }
      .disposed(by: disposeBag)
    
    pwdTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let password = owner.pwdTextField.textField.text else { return }
        owner.viewModel.checkPasswordIsValid(password: password)
      }
      .disposed(by: disposeBag)
    
    nicknameTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let nickname = owner.nicknameTextField.textField.text else { return }
        owner.viewModel.checkNicknameIsValid(nickname: nickname)
      }
      .disposed(by: disposeBag)
    
    emailTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let email = owner.emailTextField.textField.text else { return }
        owner.viewModel.checkEmailIsValid(email: email)
      }
      .disposed(by: disposeBag)
    
    repwdTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let password = owner.pwdTextField.textField.text,
              let repassword = owner.repwdTextField.textField.text else { return }
        owner.viewModel.checkRepasswordIsEqual(password: password, repassword: repassword)
      }
      .disposed(by: disposeBag)
    
    checkEmailTextField.textField.rx.controlEvent(.editingDidEnd)
      .subscribe(with: self) { owner, _ in
        guard let authCode = owner.checkEmailTextField.textField.text else { return }
        owner.viewModel.checkAuthCodeIsValid(authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    registerButton.rx.tap
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, _ in
//        owner.idTextField.removeError()
//        owner.repwdTextField.removeError()
        guard let id = owner.idTextField.textField.text,
              let email = owner.emailTextField.textField.text,
              let password = owner.pwdTextField.textField.text,
              let nickname = owner.nicknameTextField.textField.text,
              let authCode = owner.checkEmailTextField.textField.text else { return }
        owner.viewModel.registerMember(id: id, email: email, password: password, nickname: nickname, authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .noEqualPassword {
          owner.repwdTextField.setError(description: error.description!)
        } else if error == .existSameUserError {
          owner.idTextField.setError(description: error.description!)
        } else if error == .unvalidpasswordFormat {
          owner.pwdTextField.setError(description: error.description!)
        } else if error == .unvalidAuthCode {
          owner.checkEmailTextField.setError(description: error.description!)
        } else if error == .unvalidNicknameFormat {
          owner.nicknameTextField.setError(description: error.description!)
        } else if error == .unvalidUserIDFormat {
          owner.idTextField.setError(description: error.description!)
        } else if error == .unvalidEmailFormat {
          owner.emailTextField.setError(description: error.description!)
        } else if error == .expireAuthCode {
          owner.checkEmailTextField.setError(description: error.description!)
        }
        
      }
      .disposed(by: disposeBag)
    
    viewModel.successMessage
      .emit(with: self) { owner, success in
        if success == .noEqualPassword {
          owner.repwdTextField.removeError()
        } else if success == .existSameUserError {
          owner.idTextField.removeError()
        } else if success == .unvalidpasswordFormat {
          owner.pwdTextField.removeError()
        } else if success == .unvalidAuthCode {
          owner.checkEmailTextField.removeError()
        } else if success == .unvalidNicknameFormat {
          owner.nicknameTextField.removeError()
        } else if success == .unvalidUserIDFormat {
          owner.idTextField.removeError()
        } else if success == .unvalidEmailFormat {
          owner.emailTextField.removeError()
        }
        
      }
      .disposed(by: disposeBag)
    
    viewModel.signupSuccessMessage
      .emit(onNext: { _ in 
        let vc = LoginViewController()
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
      })
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    panGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
    
    viewModel.isRegisterButtonEnabled
      .drive(with: self) { owner, isEnabled in
        owner.registerButton.isEnabled = isEnabled
        owner.registerButton.setupButtonType(type: isEnabled ? .apply : .cancel )
      }
      .disposed(by: disposeBag)
    
    viewModel.isSendAuthCodeButtonEnabled
      .drive(with: self) { owner, isEnabled in
        owner.checkEmailTextField.setButtonType(isEnabled: isEnabled)
      }
      .disposed(by: disposeBag)
    
    viewModel.isSuccessRequestAuthCode
      .filter { $0 }
      .drive(with: self) { owner, isSuccess in
        print("이메일 요청 성공")
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Constants

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

// MARK: - RegisterTextFieldDelegate

extension RegisterViewController: HaramTextFieldDelegate {
  func didTappedButton() {
    guard let email = emailTextField.textField.text else { return }
    viewModel.requestEmailAuthCode(email: email)
    view.endEditing(true)
  }
  
  func didTappedReturnKey() {
    LogHelper.log("리턴 선택", level: .debug)
    view.endEditing(true)
  }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == idTextField.textField {
      nicknameTextField.textField.becomeFirstResponder()
    } else if textField == nicknameTextField.textField {
      pwdTextField.textField.becomeFirstResponder()
    } else if textField == pwdTextField.textField {
      repwdTextField.textField.becomeFirstResponder()
    } else if textField == repwdTextField.textField {
      emailTextField.textField.becomeFirstResponder()
    } else if textField == emailTextField.textField {
      checkEmailTextField.textField.becomeFirstResponder()
    } else if textField == checkEmailTextField.textField {
      checkEmailTextField.textField.resignFirstResponder()
    }
    return true
  }
}

// MARK: - UIGestureRecognizerDelegate

extension RegisterViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension RegisterViewController: KeyboardResponder {
  public var targetView: UIView {
    view
  }
}
