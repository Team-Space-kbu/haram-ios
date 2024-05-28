//
//  UpdatePasswordViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit
import RxSwift

final class UpdatePasswordViewController: BaseViewController {
  
  private let viewModel: UpdatePasswordViewModelType
  private let userEmail: String
  private let authCode: String
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "비밀번호 변경🔑"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "비밀번호를 재설정하기 위해\n새로 변경할 비밀번호를 입력해주세요"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let passwordTextField = HaramTextField(
    title: "비밀번호",
    placeholder: "Password",
    options: .errorLabel
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let checkPasswordTextField = HaramTextField(
    title: "비밀번호 확인",
    placeholder: "Password",
    options: .errorLabel
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
//    $0.isLayoutMarginsRelativeArrangement = true
//    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.distribution = .fillEqually
  }
  
  private let cancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "취소", contentInsets: .zero)
  }
  
  private let continueButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "변경하기", contentInsets: .zero)
  }
  
  init(userEmail: String, authCode: String, viewModel: UpdatePasswordViewModelType = UpdatePasswordViewModel()) {
    self.authCode = authCode
    self.viewModel = viewModel
    self.userEmail = userEmail
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeKeyboardNotification()
  }
  
  override func setupStyles() {
    super.setupStyles()
    registerKeyboardNotification()
    navigationController?.navigationBar.isHidden = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView].forEach { view.addSubview($0) }
    [cancelButton, continueButton].forEach { buttonStackView.addArrangedSubview($0) }
    [titleLabel, alertLabel, passwordTextField, checkPasswordTextField, buttonStackView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    alertLabel.snp.makeConstraints {
      $0.height.equalTo(38)
    }

    passwordTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }
    
    checkPasswordTextField.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(73)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(10, after: passwordTextField)
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
    
    [cancelButton, continueButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(48)
      }
    }
  }
  
  override func bind() {
    super.bind()
    
    passwordTextField.rx.text.orEmpty
      .skip(1)
      .subscribe(with: self) { owner, password in
        owner.viewModel.password.onNext(password)
      }
      .disposed(by: disposeBag)
    
    checkPasswordTextField.rx.text.orEmpty
      .skip(1)
      .subscribe(with: self) { owner, rePassword in
        owner.viewModel.rePassword.onNext(rePassword)
      }
      .disposed(by: disposeBag)
    
    
    passwordTextField.textField.rx.controlEvent(.editingDidEnd)
      .withLatestFrom(passwordTextField.rx.text.orEmpty)
      .subscribe(with: self) { owner, password in
        guard !password.isEmpty else { return }
        
        if let checkUpdatePassword = owner.checkPasswordTextField.textField.text,
           !checkUpdatePassword.isEmpty {
          owner.viewModel.isEqualPasswordAndRePassword(password: password, repassword: checkUpdatePassword)
        }
        
        owner.viewModel.checkPassword(password: password)
      }
      .disposed(by: disposeBag)
    
    checkPasswordTextField.textField.rx.controlEvent(.editingDidEnd)
      .withLatestFrom(passwordTextField.rx.text.orEmpty)
      .subscribe(with: self) { owner, password in
        guard let checkPassword = owner.checkPasswordTextField.textField.text,
              !checkPassword.isEmpty else { return }
        owner.viewModel.isEqualPasswordAndRePassword(password: password, repassword: checkPassword)
      }
      .disposed(by: disposeBag)
    
    continueButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        guard let password = owner.passwordTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        owner.view.endEditing(true)
        owner.viewModel.requestUpdatePassword(password: password, authCode: owner.authCode, userMail: owner.userEmail)
      }
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isValidPassword
      .emit(with: self) { owner, isValid in
        if !isValid {
          owner.passwordTextField.snp.updateConstraints {
            $0.height.equalTo(73 + 28 + 28)
          }
          owner.passwordTextField.setError(description: "비밀번호는 8~255자, 영어, 숫자, 특수문자가 적어도 하나이상씩 있어야합니다.")
        } else {
          owner.passwordTextField.snp.updateConstraints {
            $0.height.equalTo(73)
          }
          owner.passwordTextField.removeError()
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.isContinueButtonEnabled
      .drive(with: self) { owner, isEnabled in
        owner.continueButton.isEnabled = isEnabled
      }
      .disposed(by: disposeBag)
    
    viewModel.successUpdatePassword
      .emit(with: self) { owner, _ in
        AlertManager.showAlert(title: "비밀번호 변경 성공", message: "로그인창으로 이동합니다.", viewController: owner) {
          let vc = LoginViewController()
          (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        } else if error == .noEqualPassword {
          owner.checkPasswordTextField.setError(description: error.description!)
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.successMessage
      .emit(with: self) { owner, error in
        if error == .noEqualPassword {
          owner.checkPasswordTextField.removeError()
        }
      }
      .disposed(by: disposeBag)
  }
}

extension UpdatePasswordViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc
  func keyboardWillShow(_ sender: Notification) {
    guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }

    let keyboardHeight = keyboardSize.height

    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 + keyboardHeight : 12 + keyboardHeight)
    }

    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
    }
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

