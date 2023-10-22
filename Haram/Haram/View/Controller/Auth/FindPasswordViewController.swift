//
//  FindPasswordViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

final class FindPasswordViewController: BaseViewController {
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 101, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "비밀번호 찾기🔐"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "비밀번호를 재설정하기 위해 코드를 인증해야합니다.\n사용자 이메일을 입력해주세요"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let schoolEmailTextField = RegisterTextField(
    title: "학교 이메일",
    placeholder: "Email",
    options: [.defaultEmail]
  )
  
  private let continueButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "계속하기")
  }
  
  private let reRequestAlertView = RerequestAlertView()
  
  deinit {
    removeKeyboardNotification()
  }
  
  override func setupStyles() {
    super.setupStyles()
    registerKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView, continueButton].forEach { view.addSubview($0) }
    [titleLabel, alertLabel, schoolEmailTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    reRequestAlertView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    continueButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    continueButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.containerView.insertArrangedSubview(owner.reRequestAlertView, at: 3)
      }
      .disposed(by: disposeBag)
  }
}

extension FindPasswordViewController {
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
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24 + keyboardHeight)
    }

//    if self.view.window?.frame.origin.y == 0 {
//      self.view.window?.frame.origin.y -= keyboardHeight
//    }

    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

//    self.view.window?.frame.origin.y = 0
    continueButton.snp.updateConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}
