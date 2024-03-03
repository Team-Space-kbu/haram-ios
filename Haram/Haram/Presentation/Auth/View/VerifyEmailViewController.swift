

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class VerifyEmailViewController: BaseViewController {
  
  private let viewModel: VerifyEmailViewModelType
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 101, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "이메일 인증 📨"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "서비스를 이용하기 전 학생인지 확인 절차입니다\n비밀번호를 찾거나 정보를 찾을 때 사용됩니다."
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let schoolEmailTextField = HaramTextField(
    title: "학교 이메일",
    placeholder: "Email",
    options: [.defaultEmail, .errorLabel]
  ).then {
    $0.textField.keyboardType = .emailAddress
  }
  
  private lazy var checkEmailTextField = HaramTextField(
    title: "이메일 확인",
    placeholder: "확인코드",
    options: [.addButton, .errorLabel]
  ).then {
    $0.delegate = self
    $0.textField.isSecureTextEntry = true
  }
  
  private let continueButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "계속하기")
  }
  
  init(viewModel: VerifyEmailViewModelType = VerifyEmailViewModel()) {
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
    [containerView, continueButton].forEach { view.addSubview($0) }
    [titleLabel, alertLabel, schoolEmailTextField, checkEmailTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    schoolEmailTextField.snp.makeConstraints {
      $0.height.equalTo(74) // 에러라벨이 없는 경우 높이 74, 있다면 74 + 28
    }
    
    checkEmailTextField.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(74)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    continueButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(24)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
    
  }
  
  override func bind() {
    super.bind()
    
    checkEmailTextField.rx.text.orEmpty
      .skip(1)
      .subscribe(with: self) { owner, authCode in
        owner.viewModel.authCode.onNext(authCode)
      }
      .disposed(by: disposeBag)
    
    viewModel.successSendAuthCode
      .emit(with: self) { owner, message in
        owner.schoolEmailTextField.snp.updateConstraints {
          $0.height.equalTo(74)
        }
        
        owner.checkEmailTextField.setError(description: message, textColor: .hex2F80ED)
        owner.checkEmailTextField.setButtonType(isEnabled: false)
        owner.schoolEmailTextField.removeError()
        owner.schoolEmailTextField.textField.isEnabled = false
      }
      .disposed(by: disposeBag)
    
    viewModel.successVerifyAuthCode
      .emit(with: self) { owner, _ in
        let userMail = owner.schoolEmailTextField.textField.text!
        let vc = RegisterViewController(email: userMail)
        owner.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .unvalidEmailFormat {
          owner.schoolEmailTextField.snp.updateConstraints {
            $0.height.equalTo(74 + 28)
          }
          owner.schoolEmailTextField.setError(description: error.description!)
        } else if error == .expireAuthCode {
          owner.checkEmailTextField.setError(description: error.description!)
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.isContinueButtonEnabled
      .drive(with: self) { owner, isContinueButtonEnabled in
        owner.continueButton.isEnabled = isContinueButtonEnabled
        owner.continueButton.setupButtonType(type: isContinueButtonEnabled ? .apply : .cancel)
      }
      .disposed(by: disposeBag)
    
    continueButton.rx.tap
      .withLatestFrom(
        Observable.zip(
          schoolEmailTextField.rx.text.orEmpty,
          checkEmailTextField.rx.text.orEmpty
        )
      )
      .subscribe(with: self) { owner, result in
        let (userMail, authCode) = result
        owner.viewModel.verifyEmailAuthCode(userMail: userMail, authCode: authCode)
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
  }
}

extension VerifyEmailViewController: HaramTextFieldDelegate {
  func didTappedButton() {
    guard let email = schoolEmailTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    viewModel.requestEmailAuthCode(email: email)
    view.endEditing(true)
  }
  
  func didTappedReturnKey() {
    LogHelper.log("리턴 선택", level: .debug)
    view.endEditing(true)
  }
}

extension VerifyEmailViewController {
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
    
    continueButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(24 + keyboardHeight)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    
    continueButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(24)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}
