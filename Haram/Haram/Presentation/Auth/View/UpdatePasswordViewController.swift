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
  )
  
  private let checkPasswordTextField = HaramTextField(
    title: "비밀번호 확인",
    placeholder: "Password"
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.distribution = .fillEqually
  }
  
  private let cancelButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "취소")
  }
  
  private let continueButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "계속하기")
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
    [containerView, buttonStackView].forEach { view.addSubview($0) }
    [cancelButton, continueButton].forEach { buttonStackView.addArrangedSubview($0) }
    [titleLabel, alertLabel, passwordTextField, checkPasswordTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }

    passwordTextField.snp.makeConstraints {
      $0.height.equalTo(73)
//      $0.height.greaterThanOrEqualTo(46 + 18 + 10)
    }
    
    checkPasswordTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(10, after: passwordTextField)
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(24)
      $0.directionalHorizontalEdges.equalToSuperview()
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
        owner.viewModel.checkPassword(password: password)
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
    
    viewModel.IsValidPassword
      .emit(with: self) { owner, isValid in
        if !isValid {
          owner.passwordTextField.snp.updateConstraints {
            $0.height.equalTo(73 + 28)
          }
          owner.passwordTextField.setError(description: "암호 규칙이 올바르지 않습니다.")
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
        owner.continueButton.setupButtonType(type: isEnabled ? .apply : .cancel )
      }
      .disposed(by: disposeBag)
    
    viewModel.successUpdatePassword
      .emit(with: self) { owner, _ in
        let vc = LoginViewController()
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
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
      $0.bottom.equalToSuperview().inset(24 + keyboardHeight)
    }

    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(24)
    }
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

