//
//  FindPasswordViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift

final class CheckEmailViewController: BaseViewController {
  
  private let userMail: String
  private let viewModel: CheckEmailViewModelType
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "비밀번호 찾기📩"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "입력하신 이메일로 인증 코드를 발송했습니다.\n이메일을 확인해주세요📬"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let checkEmailTextField = HaramTextField(
    title: "이메일 확인",
    placeholder: "확인코드",
    options: .errorLabel
  ).then {
    $0.textField.keyboardType = .numberPad
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.distribution = .fillEqually
  }
  
  private let cancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "취소", contentInsets: .zero)
  }
  
  private let continueButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "계속하기", contentInsets: .zero)
  }
  
  private lazy var reRequestAlertView = RerequestAlertView().then {
    $0.delegate = self
  }
  
  init(userMail: String, viewModel: CheckEmailViewModelType = CheckEmailViewModel()) {
    self.userMail = userMail
    self.viewModel = viewModel
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
    [titleLabel, alertLabel, checkEmailTextField, reRequestAlertView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    alertLabel.snp.makeConstraints {
      $0.height.equalTo(38)
    }
    
    checkEmailTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }
    
    reRequestAlertView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    buttonStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
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
    
    checkEmailTextField.rx.text.orEmpty
      .skip(1)
      .subscribe(with: self) { owner, authCode in
        owner.viewModel.emailAuthCode.onNext(authCode)
      }
      .disposed(by: disposeBag)
    
    continueButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withLatestFrom(checkEmailTextField.rx.text.orEmpty)
      .subscribe(with: self) { owner, authCode in
        owner.view.endEditing(true)
        owner.viewModel.verifyEmailAuthCode(userMail: owner.userMail, authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    viewModel.verifyEmailAuthCode
      .emit(with: self) { owner, authCode in
          owner.checkEmailTextField.snp.updateConstraints {
            $0.height.equalTo(73)
          }
          owner.checkEmailTextField.removeError()
          let vc = UpdatePasswordViewController(userEmail: owner.userMail, authCode: authCode)
          owner.navigationController?.pushViewController(vc, animated: true)
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
          return
        }
        
        owner.checkEmailTextField.snp.updateConstraints {
          $0.height.equalTo(73 + 28)
        }
        owner.checkEmailTextField.setError(description: error.description!)
      }
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.continueButtonIsEnabled
      .drive(with: self) { owner, isEnabled in
        owner.continueButton.isEnabled = isEnabled
      }
      .disposed(by: disposeBag)
    
    viewModel.successSendAuthCode
      .emit(with: self) { owner, _ in
        AlertManager.showAlert(title: "인증번호발송 알림", message: "해당 메일로 인증코드를 보내는데 성공했습니다.", viewController: owner, confirmHandler: nil)
      }
      .disposed(by: disposeBag)
    
  }
}

extension CheckEmailViewController {
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

extension CheckEmailViewController: RerequestAlertViewDelegate {
  func didTappedRequestAuthCode() {
    viewModel.requestEmailAuthCode(email: self.userMail)
  }  
}
