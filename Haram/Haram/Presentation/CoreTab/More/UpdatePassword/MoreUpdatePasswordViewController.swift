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
  
  private lazy var scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.delegate = self
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: 15, right: 15)
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
    registerKeyboardNotification()
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.addGestureRecognizer(tapGesture)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [cancelButton, continueButton].forEach { buttonStackView.addArrangedSubview($0) }
    [titleLabel, alertLabel, passwordTextField, updatepPasswordTextField, checkUpdatePasswordTextField, buttonStackView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
      $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    alertLabel.snp.makeConstraints {
      $0.height.equalTo(38)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }

    updatepPasswordTextField.snp.makeConstraints {
      $0.height.equalTo(73)
    }
    
    checkUpdatePasswordTextField.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(73)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(10, after: passwordTextField)
    containerView.setCustomSpacing(10, after: updatepPasswordTextField)
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
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
          AlertManager.showAlert(on: self.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        } else if error == .noEqualPassword {
          owner.checkUpdatePasswordTextField.setError(description: error.description!)
        } else {
          AlertManager.showAlert(on: self.navigationController, message: .custom(error.description!))
        }
      }
      .disposed(by: disposeBag)
  }
}

extension MoreUpdatePasswordViewController {
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
      $0.bottom.equalToSuperview().inset(keyboardHeight)
    }

    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview()
    }
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

extension MoreUpdatePasswordViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
      // 위에서 아래로 스크롤하는 경우
      view.endEditing(true)
    }
  }
}
