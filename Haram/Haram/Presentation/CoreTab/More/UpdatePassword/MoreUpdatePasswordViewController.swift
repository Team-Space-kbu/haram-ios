//
//  MoreUpdatePasswordViewController.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class MoreUpdatePasswordViewController: BaseViewController {
  
  private let viewModel: MoreUpdatePasswordViewModel
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "비밀번호 변경🔑"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "비밀번호를 재설정하기 위해\n새로 변경할 비밀번호를 입력해주세요"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let passwordTextField = HaramTextField(
    title: "기존 비밀번호",
    placeholder: "Password",
    options: .errorLabel
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let updatepPasswordTextField = HaramTextField(
    title: "비밀번호",
    placeholder: "Password",
    options: .errorLabel
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let checkUpdatePasswordTextField = HaramTextField(
    title: "비밀번호 확인",
    placeholder: "Password",
    options: .errorLabel
  ).then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
  }
  
  private let cancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "취소", contentInsets: .zero)
  }
  
  private let continueButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "변경하기", contentInsets: .zero)
  }
  
  private let tapGesture = UITapGestureRecognizer(target: MoreUpdatePasswordViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(viewModel: MoreUpdatePasswordViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.addGestureRecognizer(tapGesture)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView, buttonStackView].forEach { view.addSubview($0) }
    [cancelButton, continueButton].forEach { buttonStackView.addArrangedSubview($0) }
    [titleLabel, alertLabel, passwordTextField, updatepPasswordTextField, checkUpdatePasswordTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(10, after: passwordTextField)
    containerView.setCustomSpacing(10, after: updatepPasswordTextField)
    
    buttonStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(Device.isNotch ? -6 : -12)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    let input = MoreUpdatePasswordViewModel.Input(
      didEditOldPassword: passwordTextField.rx.text.orEmpty.asObservable(),
      didEditNewPassword: updatepPasswordTextField.rx.text.orEmpty.asObservable(),
      didEditCheckNewPassword: checkUpdatePasswordTextField.rx.text.orEmpty.asObservable(),
      didTapCancelButton: cancelButton.rx.tap.asObservable(),
      didTapUpdateButton: continueButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
 
    output.isContinueButtonEnabled
      .bind(to: continueButton.rx.isEnabled)
      .disposed(by: disposeBag)

    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        } else if error == .noEqualPassword {
          owner.checkUpdatePasswordTextField.setError(description: error.description!)
        } else {
          AlertManager.showAlert(on: owner.navigationController, message: .custom(error.description!))
        }
      }
      .disposed(by: disposeBag)
  }
}
