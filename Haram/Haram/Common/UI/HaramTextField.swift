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

final class HaramTextField: UIView {
  
  // MARK: - Property
  
  private let options: HaramTextFieldOptions
  
  // MARK: - UI Components
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 10
  }
  
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
  
  // MARK: - Initializations
  
  init(
    title: String? = nil,
    placeholder: String,
    options: HaramTextFieldOptions = []
  ) {
    self.options = options
    super.init(frame: .zero)
    configureUI(title: title, placeholder: placeholder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func configureUI(title: String?, placeholder: String) {
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.hex9F9FA4]
    )
    
    addSubview(contentStackView)
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    if let title = title {
      titleLabel.text = title
      
      contentStackView.addArrangedSubview(titleLabel)
    }
    contentStackView.addArrangedSubview(textField)
    textField.snp.makeConstraints {
      $0.height.equalTo(44)
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
    if contentStackView.subviews.contains(errorLabel) {
      UIView.animate(withDuration: 0.2, animations: {
        self.errorLabel.alpha = 0
      }, completion: { _ in
        self.errorLabel.removeFromSuperview()
      })
    }
  }
  
  func setError(description: String, textColor: UIColor = .red) {
    guard options.contains(.errorLabel) else { return }
    errorLabel.text = description
    errorLabel.textColor = textColor
    
    if !contentStackView.subviews.contains(errorLabel) {
      errorLabel.alpha = 0
      contentStackView.addArrangedSubview(errorLabel)
      
      UIView.animate(withDuration: 0.2) {
        self.errorLabel.alpha = 1
      }
    }
  }
}

struct HaramTextFieldOptions: OptionSet {
  let rawValue: UInt
  
  static let defaultEmail = HaramTextFieldOptions(rawValue: 1 << 0) // 디폴트 이메일
  static let errorLabel = HaramTextFieldOptions(rawValue: 1 << 1) // 에러 라벨 추가
  
}

extension Reactive where Base: HaramTextField {
  var text: ControlProperty<String?> {
    return base.textField.rx.text
  }
}
