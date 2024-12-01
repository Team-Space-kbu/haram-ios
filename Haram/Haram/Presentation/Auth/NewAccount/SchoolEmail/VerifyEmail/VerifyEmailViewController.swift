

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class VerifyEmailViewController: BaseViewController {
  
  private let viewModel: VerifyEmailViewModel
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "이메일 인증 📨"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "서비스를 이용하기 전 학생인지 확인 절차입니다\n비밀번호를 찾거나 정보를 찾을 때 사용됩니다."
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let schoolEmailTextField = HaramTextField(
    title: "학교 이메일",
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
  
  init(viewModel: VerifyEmailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [cancelButton, continueButton].forEach { buttonStackView.addArrangedSubview($0) }
    [containerView, buttonStackView].forEach { view.addSubview($0) }
    [titleLabel, alertLabel, schoolEmailTextField].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    schoolEmailTextField.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(74) // 에러라벨이 없는 경우 높이 74, 있다면 74 + 28
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
    
    [cancelButton, continueButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(48)
      }
    }
  }
  
  override func bind() {
    super.bind()
    let input = VerifyEmailViewModel.Input(
      didEditSchoolEmail: schoolEmailTextField.rx.text.orEmpty.asObservable(),
      didTapContinueButton: continueButton.rx.tap.asObservable(),
      didTapCancelButton: cancelButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.errorMessageRelay
      .subscribe(with: self) { owner, error in
        if error == .unvalidEmailFormat {
          owner.schoolEmailTextField.setError(description: error.description!)
        } else if error == .requestTimeOut {
          AlertManager.showAlert(title: "Space 알림", message: error.description!, viewController: owner, confirmHandler: nil)
        } else if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
    
    //    output.isContinueButtonRelay
    
    //    output.
    //    viewModel.successSendAuthCode
    //      .emit(with: self) { owner, _ in
    //        let userMail = owner.schoolEmailTextField.textField.text!
    //        let vc = CheckAuthCodeViewController(userMail: userMail)
    //        owner.navigationItem.largeTitleDisplayMode = .never
    //        owner.navigationController?.pushViewController(vc, animated: true)
    //        owner.schoolEmailTextField.textField.text = nil
    //        owner.schoolEmailTextField.removeError()
    //      }
    //      .disposed(by: disposeBag)
    //    
    //    viewModel.errorMessage
    //      .emit(with: self) { owner, error in
    //        if error == .unvalidEmailFormat {
    //          owner.schoolEmailTextField.setError(description: error.description!)
    //        } else if error == .requestTimeOut {
    //          AlertManager.showAlert(title: "Space 알림", message: error.description!, viewController: owner, confirmHandler: nil)
    //        } else if error == .networkError {
    //          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
    //            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    //            if UIApplication.shared.canOpenURL(url) {
    //              UIApplication.shared.open(url)
    //            }
    //          }
    //        }
    //      }
    //      .disposed(by: disposeBag)
    
    //    continueButton.rx.tap
    //      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
    //      .subscribe(with: self) { owner, _ in
    //        guard let userMail = owner.schoolEmailTextField.textField.text else {
    //          return
    //        }
    //        owner.viewModel.requestEmailAuthCode(email: userMail)
    //        owner.view.endEditing(true)
    //      }
    //      .disposed(by: disposeBag)
    
    //    cancelButton.rx.tap
    //      .subscribe(with: self) { owner, _ in
    //        owner.navigationController?.popViewController(animated: true)
    //      }
    //      .disposed(by: disposeBag)
  }
}

extension VerifyEmailViewController {
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
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 + keyboardHeight : 12 + keyboardHeight)
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    
    buttonStackView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}
