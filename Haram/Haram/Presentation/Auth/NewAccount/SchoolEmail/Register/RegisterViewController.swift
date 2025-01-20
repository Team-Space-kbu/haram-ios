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
  
  private let viewModel: RegisterViewModel
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
  }
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 25
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: 49, right: 15)
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
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let repwdTextField = HaramTextField(
    title: Constants.repassword.title,
    placeholder: Constants.repassword.placeholder,
    options: [.errorLabel]
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let nicknameTextField = HaramTextField(
    title: Constants.nickname.title,
    placeholder: Constants.nickname.placeholder,
    options: [.errorLabel]
  )
  
  private let emailTextField = HaramTextField(
    title: Constants.schoolEmail.title,
    placeholder: Constants.schoolEmail.placeholder,
    options: [.defaultEmail, .errorLabel]
  ).then {
    $0.isUserInteractionEnabled = false
  }
  
  private let registerButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "회원가입", contentInsets: .zero)
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  private let tapGesture = UITapGestureRecognizer(target: RegisterViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: RegisterViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
    view.addGestureRecognizer(tapGesture)
    [idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField].forEach { $0.textField.delegate = self }
    
    registerNotifications()
    
    scrollView.delegate = self
    emailTextField.textField.text = viewModel.verifiedEmail
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [scrollView, indicatorView].map { view.addSubview($0) }
    scrollView.addSubview(stackView)
    scrollView.addSubview(registerButton)
    [titleLabel, alertLabel, idTextField, nicknameTextField, pwdTextField, repwdTextField, emailTextField].forEach { stackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
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
      $0.top.greaterThanOrEqualTo(stackView.snp.bottom)
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
    }
    
    [idTextField, pwdTextField, repwdTextField, nicknameTextField, emailTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.greaterThanOrEqualTo(46 + 18 + 10)
      }
    }
  }
  
  override func bind() {
    super.bind()
    let input = RegisterViewModel.Input(
      didEditID: idTextField.rx.text.orEmpty.asObservable(),
      didEditNickname: nicknameTextField.rx.text.orEmpty.asObservable(),
      didEditPassword: pwdTextField.rx.text.orEmpty.asObservable(),
      didEditRepassword: repwdTextField.rx.text.orEmpty.asObservable(),
      didTapRegisterButton: registerButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    output.errorMessageRelay
      .subscribe(with: self) { owner, error in
        if error == .noEqualPassword {
          owner.repwdTextField.setError(description: error.description!)
        } else if error == .existSameUserError {
          owner.idTextField.setError(description: error.description!)
        } else if error == .unvalidpasswordFormat {
          owner.pwdTextField.setError(description: error.description!)
        } else if error == .unvalidNicknameFormat {
          owner.nicknameTextField.setError(description: error.description!)
        } else if error == .unvalidUserIDFormat {
          owner.idTextField.setError(description: error.description!)
        }  else if error == .unvalidAuthCode || error == .expireAuthCode || error == .emailAlreadyUse {
          AlertManager.showAlert(message: .custom(error.description!), actions: [
            DefaultAlertButton {
              owner.navigationController?.popViewController(animated: true)
            }
          ])
        } else if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        } else if error == .containProhibitedWord || error == .alreadyUseNickName {
          AlertManager.showAlert(message: .custom(error.description!))
        } else if error == .alreadyUseUserID {
          AlertManager.showAlert(message: .custom("해당 아이디는 이미 사용중입니다\n다른 아이디로 수정해주세요."))
        } else {
          AlertManager.showAlert(message: .custom("서버측에서 알 수 없는 에러가 발생하였습니다\n다음에 다시 시도해주세요."))
        }
      }
      .disposed(by: disposeBag)
    
    output.successMessageRelay
      .subscribe(with: self) { owner, success in
        if success == .noEqualPassword {
          owner.repwdTextField.removeError()
        } else if success == .existSameUserError {
          owner.idTextField.removeError()
        } else if success == .unvalidpasswordFormat {
          owner.pwdTextField.removeError()
        } else if success == .unvalidNicknameFormat {
          owner.nicknameTextField.removeError()
        } else if success == .unvalidUserIDFormat {
          owner.idTextField.removeError()
        }
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)

    output.isLoadingSubject
      .bind(to: indicatorView.rx.isAnimating)
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
      view.endEditing(true)
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

extension RegisterViewController {
  
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillShow(notification)
    }
    
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillHide(notification)
    }
  }
  
  func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  func keyboardWillShow(_ notification: Notification) {
    
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardHeight = keyboardFrame.cgRectValue.height
    
    registerButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 + keyboardHeight : 12 + keyboardHeight)
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  func keyboardWillHide(_ notification: Notification) {
    registerButton.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

extension RegisterViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
      // 위에서 아래로 스크롤하는 경우
      view.endEditing(true)
    }
  }
}
