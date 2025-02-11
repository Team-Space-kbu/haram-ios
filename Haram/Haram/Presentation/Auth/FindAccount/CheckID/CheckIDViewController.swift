//
//  CheckIDViewController.swift
//  Haram
//
//  Created by 이건준 on 11/4/24.
//

import UIKit

import RxSwift

final class CheckIDViewController: BaseViewController {
  private let viewModel: CheckIDViewModel
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "아이디 찾기📩"
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
    placeholder: "확인코드",
    options: .errorLabel
  ).then {
    $0.textField.keyboardType = .numberPad
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
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "인증코드 확인", contentInsets: .zero)
  }
  
  private let reRequestAlertView = RerequestAlertView()
  
  init(viewModel: CheckIDViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
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
    
    reRequestAlertView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(10, after: checkEmailTextField)
    
    buttonStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(Device.isNotch ? -6 : -12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    let input = CheckIDViewModel.Input(
      didTappedContinueButton: continueButton.rx.tap
        .withLatestFrom(checkEmailTextField.rx.text.orEmpty)
        .asObservable(),
      didTappedRerequestButton: reRequestAlertView.reRequestButton.rx.tap.asObservable(),
      didTapCancelButton: cancelButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.verifyEmailAuthCodeRelay
      .subscribe(with: self) { owner, authCode in
        owner.checkEmailTextField.snp.updateConstraints {
          $0.height.equalTo(74)
        }
        owner.checkEmailTextField.removeError()
      }
      .disposed(by: disposeBag)
    
    output.errorMessageRelay
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
          return
        }
        
        owner.checkEmailTextField.snp.updateConstraints {
          $0.height.equalTo(74 + 28)
        }
        
        if error == .notFindUserError {
          AlertManager.showAlert(message: .custom("해당 이메일에 대한 사용자가 존재하지않습니다\n다른 이메일로 시도해주세요."), actions: [
            DefaultAlertButton {
              owner.navigationController?.popViewController(animated: true)
            }
          ])
        } else {
          owner.checkEmailTextField.setError(description: error.description!)
        }
      }
      .disposed(by: disposeBag)
  }
}
