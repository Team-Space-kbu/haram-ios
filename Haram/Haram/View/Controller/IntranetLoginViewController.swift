//
//  IntranetLoginViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/06/06.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class IntranetLoginViewController: BaseViewController {
  
  private let viewModel: IntranetLoginViewModelType
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 95, left: 20, bottom: .zero, right: 20)
  }
  
  private let logoImageView = UIImageView().then {
    $0.image = UIImage(named: "intranetLoginLogo")
    $0.contentMode = .scaleAspectFit
  }
  
  private let loginLabel = UILabel().then {
    $0.text = "로그인"
    $0.font = .regular24
  }
  
  private let intranetLabel = UILabel().then {
    $0.text = "한국성서대학교인트라넷"
    $0.font = .regular14
  }
  
  private let idTextField = UITextField().then {
    $0.placeholder = "아이디"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.autocapitalizationType = .none
  }
  
  private let pwTextField = UITextField().then {
    $0.placeholder = "비밀번호"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.isSecureTextEntry = true
  }
  
  private let loginButton = UIButton().then {
    $0.backgroundColor = .hex79BD9A
    $0.tintColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    
    let attributedString = NSAttributedString(
      string: "로그인",
      attributes: [
        .font:UIFont.bold14,
        .foregroundColor:UIColor.white
      ]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
  }
  
  private let lastAuthButton = UIButton().then {
    let attributedString = NSAttributedString(
      string: "나중에인증하기",
      attributes: [.font:UIFont.regular14]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
    $0.setTitleColor(.label, for: .normal)
  }
  
  init(viewModel: IntranetLoginViewModelType = IntranetLoginViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  override func setupStyles() {
    super.setupStyles()
    registerKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerStackView)
    view.addSubview(lastAuthButton)
    [logoImageView, loginLabel, intranetLabel, idTextField, pwTextField, loginButton].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    logoImageView.snp.makeConstraints {
      $0.width.equalTo(300)
      $0.height.equalTo(210)
    }
    
    [idTextField, pwTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(55)
      }
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    lastAuthButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
    
    containerStackView.setCustomSpacing(28, after: intranetLabel)
  }
  
  override func bind() {
    super.bind()
    
    loginButton.rx.tap
      .subscribe(with: self) { owner, _ in
        guard let intranetID = owner.idTextField.text,
              let intranetPWD = owner.pwTextField.text,
              !intranetID.isEmpty && !intranetPWD.isEmpty else {
          return
        }
        owner.viewModel.intranetLoginButtonTapped.onNext(())
        owner.viewModel.whichIntranetInfo.onNext((intranetID, intranetPWD))
      }
      .disposed(by: disposeBag)
    
    lastAuthButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        UserManager.shared.clearIntranetInformation()
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = HaramTabbarController(userID: UserManager.shared.userID!)
      }
      .disposed(by: disposeBag)
    
    viewModel.successIntranetLogin
      .compactMap { $0 }
      .emit(with: self) { owner, message in
        CrawlManager.getIntranetLoginResult(html: message) { loginResult in
          switch loginResult {
          case .successIntranetLogin:
            owner.dismiss(animated: true)
          case .failedIntranetLogin:
            print("인트라넷 로그인 결과 \(loginResult.message)")
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

extension IntranetLoginViewController {
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
