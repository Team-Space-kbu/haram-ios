//
//  FindPasswordViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

final class CheckEmailViewController: BaseViewController {
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 101, left: 15, bottom: .zero, right: 15)
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
    placeholder: "확인코드"
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
  
  private let cancelButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "취소")
  }
  
  private let continueButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "계속하기")
  }
  
  private lazy var reRequestAlertView = RerequestAlertView()
  
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
    
    checkEmailTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }
    
    reRequestAlertView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(24)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    continueButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.view.endEditing(true)
        let vc = UpdatePasswordViewController()
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
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
      $0.bottom.equalToSuperview().inset(24 + keyboardHeight)
    }

    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(24)
    }
    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}
