//
//  RegisterTextField.swift
//  Haram
//
//  Created by 이건준 on 2023/07/31.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol HaramTextFieldDelegate: AnyObject {
  func didTappedButton()
  func didTappedReturnKey()
}

final class HaramTextField: UIView {
  
  // MARK: - Property
  
  weak var delegate: HaramTextFieldDelegate?
  private let disposeBag = DisposeBag()
  private let options: HaramTextFieldOptions
  
  // MARK: - UI Components
  
  private let titleLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  let textField = UITextField().then {
    $0.textColor = .black
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.backgroundColor = .hexF5F5F5
    $0.leftViewMode = .always
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: .zero))
    $0.autocapitalizationType = .none
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
  }
  
  private lazy var errorLabel = UILabel().then {
    $0.textColor = .red
    $0.font = .regular14
    $0.numberOfLines = 0
    $0.textAlignment = .left
  }
  
  private lazy var defaultLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex9F9FA4
    $0.text = "@bible.ac.kr  "
    $0.textAlignment = .left
  }
  
  private lazy var haramButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "확인코드발송", contentInsets: .zero)
  }
  
  // MARK: - Initializations
  
  init(
    title: String? = nil,
    placeholder: String,
    options: HaramTextFieldOptions = []
  ) {
    self.options = options
    super.init(frame: .zero)
    configureUI(title: title, placeholder: placeholder)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func bind() {
    haramButton.rx.tap
      .throttle(.seconds(3), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedButton()
      }
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEndOnExit)
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedButton()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI(title: String?, placeholder: String) {
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.hex9F9FA4]
    )
    
    /// 만약에 타이틀이 존재하는 경우
    if let title = title {
      titleLabel.text = title
      addSubview(titleLabel)
      addSubview(textField)
      titleLabel.snp.makeConstraints {
        $0.top.directionalHorizontalEdges.equalToSuperview()
//        $0.trailing.lessThanOrEqualToSuperview()
        $0.height.equalTo(18)
      }
      
      textField.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        $0.leading.equalToSuperview()
        $0.width.equalTo(UIScreen.main.bounds.width - 30)
        $0.height.equalTo(46)
      }
    } else {
      /// 모든 HaramTextField는 textField를 가지고있음
      addSubview(textField)
      textField.snp.makeConstraints {
        $0.top.directionalHorizontalEdges.equalToSuperview()
        $0.height.equalTo(46)
      }
    }
    
    
    if options.contains(.addButton) {
      addSubview(haramButton)
      
      textField.snp.updateConstraints {
        $0.width.equalTo(182)
      }
      
      haramButton.snp.makeConstraints {
        $0.leading.equalTo(textField.snp.trailing).offset(196 - 15 - 167)
        $0.centerY.equalTo(textField)
        $0.trailing.equalToSuperview()
        $0.height.equalTo(46)
      }
    }
    
    if options.contains(.defaultEmail) {
      textField.rightViewMode = .always
      textField.rightView = defaultLabel
    }
  }
}

// MARK: - Public Functions

extension HaramTextField {
  func removeError() {
    guard options.contains(.errorLabel) else { return }
    if subviews.contains(errorLabel) {
      errorLabel.removeFromSuperview()
    }
  }
  
  func setError(description: String, textColor: UIColor = .red) {
    guard options.contains(.errorLabel) else { return }
    addSubview(errorLabel)
    errorLabel.snp.makeConstraints {
      $0.top.equalTo(textField.snp.bottom).offset(10)
//      $0.trailing.lessThanOrEqualToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    errorLabel.text = description
    errorLabel.textColor = textColor
  }
  
  func setButtonType(isEnabled: Bool) {
    haramButton.isEnabled = isEnabled
  }
}

struct HaramTextFieldOptions: OptionSet {
  let rawValue: UInt
  
  static let defaultEmail = HaramTextFieldOptions(rawValue: 1 << 0) // 디폴트 이메일
  static let addButton = HaramTextFieldOptions(rawValue: 1 << 1) // 버튼 추가
  static let errorLabel = HaramTextFieldOptions(rawValue: 1 << 2) // 에러 라벨 추가
  
}

extension Reactive where Base: HaramTextField {
  var text: ControlProperty<String?> {
    return base.textField.rx.text
  }
}
