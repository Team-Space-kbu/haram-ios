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

enum IntranetLoginType {
  case shortcut
  case noShortcut
}

final class IntranetLoginViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: IntranetLoginViewModelType
  private let type: IntranetLoginType
  
  // MARK: - UI Components
  
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
    $0.textColor = .black
    $0.font = .regular24
  }
  
  private let intranetLabel = UILabel().then {
    $0.text = "한국성서대학교인트라넷"
    $0.textColor = .black
    $0.font = .regular14
  }
  
  private let idTextField = HaramTextField(placeholder: "아이디")
  
  private let pwTextField = HaramTextField(placeholder: "비밀번호").then {
    $0.textField.isSecureTextEntry = true
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
      attributes: [.font:UIFont.regular14, .foregroundColor:UIColor.black]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
    $0.backgroundColor = .clear
  }
  
  private lazy var errorMessageLabel = UILabel().then {
    $0.textColor = .red
    $0.font = .regular14
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  // MARK: - Initialization
  
  init(type: IntranetLoginType = .noShortcut, viewModel: IntranetLoginViewModelType = IntranetLoginViewModel()) {
    self.viewModel = viewModel
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set NavigationBar
    navigationController?.setNavigationBarHidden(true, animated: true)
    
    /// Set Delegate
    idTextField.textField.delegate = self
    pwTextField.textField.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerStackView, lastAuthButton, indicatorView].forEach { view.addSubview($0) }
    [logoImageView, loginLabel, intranetLabel, idTextField, pwTextField, loginButton].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    logoImageView.snp.makeConstraints {
      $0.width.equalTo(300)
      $0.height.equalTo(210)
    }
    
    errorMessageLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    [idTextField, pwTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(45)
      }
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    lastAuthButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
    }
    
    containerStackView.setCustomSpacing(28, after: intranetLabel)
  }
  
  override func bind() {
    super.bind()
    
    loginButton.rx.tap
      .subscribe(with: self) { owner, _ in
        guard let intranetID = owner.idTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let intranetPWD = owner.pwTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !intranetID.isEmpty && !intranetPWD.isEmpty else {
          return
        }
        let isContain = owner.containerStackView.subviews.contains(owner.errorMessageLabel)
        
        if isContain {
          owner.errorMessageLabel.text = nil
          owner.errorMessageLabel.removeFromSuperview()
        }
        
        owner.view.endEditing(true)
        owner.viewModel.whichIntranetInfo.onNext((intranetID, intranetPWD))
      }
      .disposed(by: disposeBag)
    
    lastAuthButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.removeNotifications()
        owner.navigationController?.setNavigationBarHidden(false, animated: true)
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.successIntranetLogin
      .emit(with: self) { owner, message in
        owner.navigationController?.setNavigationBarHidden(false, animated: true)
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        guard error == .wrongLoginInfo else { return }
        
        let isContain = owner.containerStackView.subviews.contains(owner.errorMessageLabel)
        
        if !isContain {
          owner.containerStackView.insertArrangedSubview(owner.errorMessageLabel, at: 5)
          owner.errorMessageLabel.text = error.description
        }
        
      }
      .disposed(by: disposeBag)
  }
}

extension IntranetLoginViewController: KeyboardResponder {
  public var targetView: UIView {
    view
  }
}

extension IntranetLoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == idTextField.textField {
      pwTextField.textField.becomeFirstResponder()
    } else if textField == pwTextField.textField {
      pwTextField.textField.resignFirstResponder()
      
      guard let intranetID = self.idTextField.textField.text,
            let intranetPWD = self.pwTextField.textField.text,
            !intranetID.isEmpty && !intranetPWD.isEmpty else {
        return true
      }
      
      let isContain = self.containerStackView.subviews.contains(self.errorMessageLabel)
      
      if isContain {
        self.errorMessageLabel.removeFromSuperview()
      }
      
      viewModel.whichIntranetInfo.onNext((intranetID, intranetPWD))
    }
    return true
  }
}
