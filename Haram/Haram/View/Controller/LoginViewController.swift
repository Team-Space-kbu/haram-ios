//
//  LoginViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LoginViewController: BaseViewController {
  
  // MARK: - Propoerty
  
  private let viewModel: LoginViewModelType
  
  // MARK: - UI Components
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 22, bottom: .zero, right: 22)
    $0.spacing = 15
    $0.backgroundColor = .clear
  }
  
  private let loginImageView = UIImageView().then {
    $0.image = UIImage(named: "login")
    $0.contentMode = .scaleAspectFill
  }
  
  private let loginLabel = UILabel().then {
    $0.font = .regular24
    $0.textColor = .black
    $0.text = "로그인"
  }
  
  private let schoolLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular14
    $0.text = "한국성서대학교인트라넷"
  }
  
  private lazy var emailTextField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(
      string: "Email",
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.black]
    )
    $0.backgroundColor = .hexF5F5F5
    $0.textColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.returnKeyType = .next
    $0.autocapitalizationType = .none
    $0.delegate = self
  }
  
  private lazy var passwordTextField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(
      string: "Password",
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.black]
    )
    $0.backgroundColor = .hexF5F5F5
    $0.textColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.returnKeyType = .join
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
    $0.delegate = self
  }
  
  private lazy var errorMessageLabel = UILabel().then {
    $0.textColor = .red
    $0.font = .regular14
  }
  
  private lazy var loginButton = LoginButton().then {
    $0.delegate = self
  }
  
  private lazy var loginAlertView = LoginAlertView().then {
    $0.delegate = self
  }
  
  // MARK: - Initializations
  
  init(viewModel: LoginViewModelType = LoginViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UserManager.shared.clearAllInformations()

    guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken else {
      return
    }
    
    removeKeyboardNotification()
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = HaramTabbarController()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  // MARK: - Configure UI
  
  override func setupStyles() {
    super.setupStyles()
    registerKeyboardNotification()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.loginToken
      .skip(1)
      .drive(with: self) { owner, result in
        guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken else { return }
        
        let vc = HaramTabbarController()
        vc.modalPresentationStyle = .overFullScreen
        owner.present(vc, animated: true) { [weak self] in
          self?.removeKeyboardNotification()
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(to: errorMessageLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [loginImageView, containerView].forEach { view.addSubview($0) }
    [loginLabel, schoolLabel, emailTextField, passwordTextField, errorMessageLabel, loginButton, loginAlertView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    loginImageView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(118)
      $0.directionalHorizontalEdges.equalToSuperview().inset(77.4)
      $0.height.equalTo(248.669)
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(loginImageView.snp.bottom).offset(37.33)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [emailTextField, passwordTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(55)
      }
    }
    
    loginLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    schoolLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    loginAlertView.snp.makeConstraints {
      $0.width.equalTo(216)
      $0.height.equalTo(16)
    }
    
    containerView.setCustomSpacing(12, after: loginLabel)
    containerView.setCustomSpacing(30, after: schoolLabel)
    containerView.setCustomSpacing(83, after: loginButton)
  }
}

// MARK: - LoginButtonDelegate

extension LoginViewController: LoginButtonDelegate {
  func didTappedLoginButton() {
    guard let userID = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    view.endEditing(true)
    viewModel.tryLoginRequest.onNext((userID, password))
  }
  
  func didTappedFindPasswordButton() {
    let vc = FindPasswordViewController()
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      passwordTextField.resignFirstResponder()
      guard let userID = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return true }
      view.endEditing(true)
      viewModel.tryLoginRequest.onNext((userID, password))
    }
    return true
  }
}

// MARK: - LoginAlertViewDelegate

extension LoginViewController: LoginAlertViewDelegate {
  func didTappedRegisterButton() {
    let vc = UINavigationController(rootViewController: TermsOfUseViewController())
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  
  
}

// MARK: - Keyboard Notification

extension LoginViewController {
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
    
    if self.view.window?.frame.origin.y == 0 {
      self.view.window?.frame.origin.y -= keyboardHeight
    }

    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {

    self.view.window?.frame.origin.y = 0
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}
