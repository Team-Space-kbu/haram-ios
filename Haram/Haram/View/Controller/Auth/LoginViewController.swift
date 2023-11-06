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
    $0.keyboardType = .emailAddress
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
//    UserManager.shared.clearAllInformations()
    guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken else {
      registerNotifications()
      return
    }
    
    removeNotifications()
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = HaramTabbarController()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    
    viewModel.loginToken
      .skip(1)
      .drive(with: self) { owner, result in
        guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken else { return }
        
        let vc = HaramTabbarController()
        vc.modalPresentationStyle = .fullScreen
        owner.present(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if !owner.containerView.subviews.contains(owner.errorMessageLabel) {
          owner.containerView.insertArrangedSubview(owner.errorMessageLabel, at: 5)
        }
        owner.errorMessageLabel.text = error
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView, indicatorView].forEach { view.addSubview($0) }
    [loginImageView, loginLabel, schoolLabel, emailTextField, passwordTextField, loginButton].forEach { containerView.addArrangedSubview($0) }
    view.addSubview(loginAlertView)
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
    
//    errorMessageLabel.snp.makeConstraints {
//      $0.height.equalTo(16)
//    }
    
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
    guard let userID = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    view.endEditing(true)
    viewModel.tryLoginRequest.onNext((userID, password))
  }
  
  func didTappedFindPasswordButton() {
    let vc = UINavigationController(rootViewController: FindPasswordViewController())
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

extension LoginViewController: KeyboardResponder {
  public var targetView: UIView {
    view
  }
}
