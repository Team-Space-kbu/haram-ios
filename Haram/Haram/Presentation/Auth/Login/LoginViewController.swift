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
  
  private let viewModel: LoginViewModel
  
  // MARK: - UI Components
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
    $0.spacing = 10
    $0.backgroundColor = .clear
  }
  
  private let loginImageView = UIImageView().then {
    $0.image = UIImage(resource: .login)
    $0.contentMode = .scaleAspectFit
  }
  
  private let loginLabel = UILabel().then {
    $0.font = .regular24
    $0.textColor = .black
    $0.text = "로그인"
  }
  
  private let schoolLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular14
    $0.text = "한국성서대학교 커뮤니티"
  }
  
  private lazy var emailTextField = HaramTextField(placeholder: "아이디").then {
    $0.textField.delegate = self
    $0.textField.keyboardType = .emailAddress
    $0.textField.returnKeyType = .next
  }
  
  private lazy var passwordTextField = HaramTextField(placeholder: "비밀번호").then {
    $0.textField.delegate = self
    $0.textField.isSecureTextEntry = true
    $0.textField.returnKeyType = .join
  }
  
  private lazy var errorMessageLabel = UILabel().then {
    $0.textColor = .red
    $0.font = .regular14
  }
  
  private let loginButton = LoginButton()
  
  private let newAccountButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "새 계정 만들기"
    $0.configuration?.baseBackgroundColor = .clear
    $0.configuration?.baseForegroundColor = .hex3B8686
    $0.configuration?.font = .bold16
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.background.strokeColor = .hex79BD9A
    $0.configuration?.background.strokeWidth = 1
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  // MARK: - Initializations
  
  init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard UserManager.shared.hasToken else {
      registerNotifications()
      return
    }
    
    removeNotifications()
    
    guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { return }
    
    window.rootViewController = HaramTabbarController()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    let input = LoginViewModel.Input(
      didEditEmailField: emailTextField.rx.text.orEmpty.asObservable(),
      didEditPasswordField: passwordTextField.rx.text.orEmpty.asObservable(),
      didTappedLoginButton: loginButton.loginButton.rx.tap.asObservable(),
      didTappedNewAccountButton: newAccountButton.rx.tap.asObservable(),
      didTappedFindAccountButton: loginButton.findPasswordButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.errorMessage
      .subscribe(with: self) { owner, error in
        guard error != .timeoutError else { return }
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        } else {
          let isContain = owner.containerView.subviews.contains(owner.errorMessageLabel)
          
          if !isContain {
            owner.containerView.insertArrangedSubview(owner.errorMessageLabel, at: 4)
          }
          owner.errorMessageLabel.text = error.description!
          
        }
      }
      .disposed(by: disposeBag)
    
    output.isLoading
      .bind(to: indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [loginImageView, containerView, indicatorView, newAccountButton].forEach { view.addSubview($0) }
    [loginLabel, schoolLabel, emailTextField, passwordTextField, loginButton].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    newAccountButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(50)
    }
    
    containerView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualTo(newAccountButton.snp.top)
      $0.centerY.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [emailTextField, passwordTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(45)
      }
    }
    
    loginLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    schoolLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    errorMessageLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48 + 48)
    }
    
    containerView.setCustomSpacing(12, after: loginLabel)
    containerView.setCustomSpacing(20, after: schoolLabel)
    
    loginImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(containerView.snp.top)
    }
  }
}

// MARK: - LoginButtonDelegate

//extension LoginViewController: LoginButtonDelegate {
//  func didTappedLoginButton() {
//    guard let userID = emailTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//          let password = passwordTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//    
//    view.endEditing(true)
////    viewModel.loginMember(userID: userID, password: password)
//  }
//  
//  func didTappedFindPasswordButton() {
//    let vc = UINavigationController(rootViewController: FindAccountViewController(viewModel: .init()))
//    vc.modalPresentationStyle = .fullScreen
//    
//    present(vc, animated: true) {
//      self.errorMessageLabel.removeFromSuperview()
//      self.errorMessageLabel.text = nil
//    }
//  }
//}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField.textField {
      passwordTextField.textField.becomeFirstResponder()
    } else if textField == passwordTextField.textField {
      passwordTextField.resignFirstResponder()
      guard let userID = emailTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return true }
      
      view.endEditing(true)
//      viewModel.loginMember(userID: userID, password: password)
    }
    return true
  }
}

// MARK: - Keyboard Notification

extension LoginViewController {
  
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
    
    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let keyboardHeight = keyboardSize.height
    
    if self.containerView.transform == .init(translationX: 0, y: 0) {
      UIView.animate(withDuration: 0.1, animations: {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + 16 + 25)
      })
    }
  }
  
  func keyboardWillHide(_ notification: Notification) {
    UIView.animate(withDuration: 0.1, animations: {
      self.containerView.transform = .identity
    })
  }
}
