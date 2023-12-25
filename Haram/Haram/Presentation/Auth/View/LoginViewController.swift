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
    $0.layoutMargins = .init(top: 50, left: 22, bottom: .zero, right: 22)
    $0.spacing = 25
    $0.backgroundColor = .clear
  }
  
  private let loginImageView = UIImageView().then {
    $0.image = UIImage(named: "login")
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
    $0.text = "한국성서대학교인트라넷"
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
  
  private lazy var loginButton = LoginButton().then {
    $0.delegate = self
  }
  
  private lazy var loginAlertView = LoginAlertView().then {
    $0.delegate = self
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
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

    guard UserManager.shared.hasToken else {
      registerNotifications()
      return
    }
    
    removeNotifications()
    
    guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { return }
    
    UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
      window.rootViewController = HaramTabbarController()
       })
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    
    viewModel.successLogin
      .emit(with: self) { owner, result in
        guard UserManager.shared.hasToken else { return }
        
        let vc = HaramTabbarController()
        vc.modalPresentationStyle = .fullScreen
        owner.present(vc, animated: true) {
          owner.emailTextField.textField.text = nil
          owner.passwordTextField.textField.text = nil
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        let isContain = owner.containerView.subviews.contains(owner.errorMessageLabel)
        
        if !isContain {
          owner.errorMessageLabel.text = error
          owner.containerView.insertArrangedSubview(owner.errorMessageLabel, at: 5)
          
        }
        
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView, indicatorView, loginAlertView].forEach { view.addSubview($0) }
    [loginImageView, loginLabel, schoolLabel, emailTextField, passwordTextField, loginButton].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    loginImageView.snp.makeConstraints {
      $0.height.equalTo(248.669)
    }

    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
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
      $0.height.equalTo(48)
    }
    
    containerView.setCustomSpacing(37.33, after: loginImageView)
    containerView.setCustomSpacing(10, after: loginLabel)
    containerView.setCustomSpacing(20, after: schoolLabel)
    
    loginAlertView.snp.makeConstraints {
      $0.top.equalTo(containerView.snp.bottom).offset(41)
      $0.centerX.equalToSuperview()
      $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-41 + 16)
      $0.width.equalTo(216)
      $0.height.equalTo(16)
    }
  }
}

// MARK: - LoginButtonDelegate

extension LoginViewController: LoginButtonDelegate {
  func didTappedLoginButton() {
    guard let userID = emailTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    
    let isContain = self.containerView.subviews.contains(self.errorMessageLabel)
    
    if isContain {
      self.errorMessageLabel.text = nil
      self.errorMessageLabel.removeFromSuperview()
    }
    
    view.endEditing(true)
    viewModel.loginMember(userID: userID, password: password)
  }
  
  func didTappedFindPasswordButton() {
    let vc = UINavigationController(rootViewController: FindPasswordViewController())
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true) {
      self.errorMessageLabel.removeFromSuperview()
      self.errorMessageLabel.text = nil
    }
  }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField.textField {
      passwordTextField.textField.becomeFirstResponder()
    } else if textField == passwordTextField.textField {
      passwordTextField.resignFirstResponder()
      guard let userID = emailTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return true }
      
      let isContain = self.containerView.subviews.contains(self.errorMessageLabel)
      
      if isContain {
        self.errorMessageLabel.text = nil
        self.errorMessageLabel.removeFromSuperview()
      }
      
      view.endEditing(true)
      viewModel.loginMember(userID: userID, password: password)
    }
    return true
  }
}

// MARK: - LoginAlertViewDelegate

extension LoginViewController: LoginAlertViewDelegate {
  func didTappedRegisterButton() {
    let vc = UINavigationController(rootViewController: TermsOfUseViewController())
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true) {
      self.errorMessageLabel.removeFromSuperview()
      self.errorMessageLabel.text = nil
    }
  }
  
  
}

// MARK: - Keyboard Notification

extension LoginViewController: KeyboardResponder {
  public var targetView: UIView {
    view
  }
}
