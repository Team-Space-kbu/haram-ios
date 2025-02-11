//
//  FindIDViewController.swift
//  Haram
//
//  Created by 이건준 on 11/4/24.
//

import UIKit

final class FindIDViewController: BaseViewController {
  
  private let viewModel: FindIDViewModel
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "아이디 찾기🪪"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "사용자 아이디를 찾기 위해 이메일 인증해야합니다.\n사용자 이메일을 입력해주세요"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let schoolEmailTextField = HaramTextField(
    title: "가입된 이메일",
    placeholder: "Email",
    options: [.defaultEmail, .errorLabel]
  ).then {
    $0.textField.keyboardType = .emailAddress
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
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "인증코드 발송", contentInsets: .zero)
  }
  
  init(viewModel: FindIDViewModel) {
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
    [titleLabel, alertLabel, schoolEmailTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    buttonStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(Device.isNotch ? -6 : -12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    let input = FindIDViewModel.Input(
      didUpdatedUserMail: schoolEmailTextField.rx.text.orEmpty.asObservable(),
      didTapSendButton: continueButton.rx.tap.asObservable(), 
      didTapCancelButton: cancelButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
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
        
        if error == .requestTimeOut {
          AlertManager.showAlert(on: owner.navigationController, message: .custom(error.description!))
          return
        }
        owner.schoolEmailTextField.setError(description: error.description!)
      }
      .disposed(by: disposeBag)
  }
}
