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
  
  // MARK: - Property
  
  private let viewModel: IntranetLoginViewModel
  
  // MARK: - UI Components
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 95, left: 15, bottom: .zero, right: 15)
  }
  
  private let logoImageView = UIImageView().then {
    $0.image = UIImage(resource: .intranetLoginLogo)
    $0.contentMode = .scaleAspectFit
  }
  
  private let loginLabel = UILabel().then {
    $0.text = "로그인"
    $0.textColor = .black
    $0.font = .regular24
  }
  
  private let intranetLabel = UILabel().then {
    $0.text = "한국성서대학교 인트라넷 로그인"
    $0.textColor = .black
    $0.font = .regular14
  }
  
  private let idTextField = HaramTextField(placeholder: "아이디")
  
  private let pwTextField = HaramTextField(placeholder: "비밀번호").then {
    $0.textField.isSecureTextEntry = true
  }
  
  private let loginButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "로그인", contentInsets: .zero)
  }
  
  private let lastAuthButton = UIButton(configuration: .plain()).then {
    $0.configuration?.background.backgroundColor = .hexD8D8DA
    $0.configuration?.title = "나중에 인증하기"
    $0.configuration?.font = .regular14
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .hex2F2E41
  }
  
  private lazy var errorMessageLabel = UILabel().then {
    $0.textColor = .red
    $0.font = .regular14
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  // MARK: - Initialization
  
  init(viewModel: IntranetLoginViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
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
      $0.top.equalToSuperview()
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
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
    }
    
    containerStackView.setCustomSpacing(28, after: intranetLabel)
  }
  
  override func bind() {
    super.bind()
    
    let input = IntranetLoginViewModel.Input(
      didEditIntranetID: idTextField.rx.text.orEmpty.asObservable(),
      didEditIntranetPassword: pwTextField.rx.text.orEmpty.asObservable(),
      didTapLoginButton: loginButton.rx.tap.asObservable(),
      didTapLastAuthButton: lastAuthButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.isLoading
      .bind(to: indicatorView.rx.isAnimating)
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
        } else {
          let isContain = owner.containerStackView.subviews.contains(owner.errorMessageLabel)
          if !isContain {
            owner.containerStackView.insertArrangedSubview(owner.errorMessageLabel, at: 5)
            owner.errorMessageLabel.text = error.description
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

extension IntranetLoginViewController {
  
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillShow(notification)
    }
    
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.keyboardWillHide(notification)
    }
  }
  
  func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  func keyboardWillShow(_ notification: Notification) {
    
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let currentTextField = UIResponder.getCurrentResponder() as? UITextField else { return }
    
    // Y축으로 키보드의 상단 위치
    let keyboardTopY = keyboardFrame.cgRectValue.origin.y
    // 현재 선택한 텍스트 필드의 Frame 값
    let convertedTextFieldFrame = view.convert(
      currentTextField.frame,
      from: currentTextField.superview
    )
    // Y축으로 현재 텍스트 필드의 하단 위치
    let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
    
    // Y축으로 텍스트필드 하단 위치가 키보드 상단 위치보다 클 때 (즉, 텍스트필드가 키보드에 가려질 때가 되겠죠!)
    if textFieldBottomY > keyboardTopY {
      let textFieldTopY = convertedTextFieldFrame.origin.y
      // 노가다를 통해서 모든 기종에 적절한 크기를 설정함.
      let newFrame = textFieldTopY - keyboardTopY/1.6
      
      UIView.animate(withDuration: 0.1, animations: {
        self.containerStackView.transform = CGAffineTransform(translationX: 0, y: -newFrame)
      })
      
    }
  }
  
  func keyboardWillHide(_ notification: Notification) {
    
    UIView.animate(withDuration: 0.1, animations: {
      self.containerStackView.transform = .identity
    })
  }
}

extension IntranetLoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == idTextField.textField {
      pwTextField.textField.becomeFirstResponder()
    } else if textField == pwTextField.textField {
      pwTextField.textField.resignFirstResponder()
      
      let isContain = self.containerStackView.subviews.contains(self.errorMessageLabel)
      
      if isContain {
        self.errorMessageLabel.removeFromSuperview()
      }
    }
    return true
  }
}

extension IntranetLoginViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
