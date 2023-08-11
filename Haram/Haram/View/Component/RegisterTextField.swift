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

protocol RegisterTextFieldDelegate: AnyObject {
  func didTappedButton()
  func didTappedReturnKey()
}

final class RegisterTextField: UIView {
  
  weak var delegate: RegisterTextFieldDelegate?
  private let disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  let textField = UITextField().then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.backgroundColor = .hexF5F5F5
    $0.leftViewMode = .always
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 31 - 15, height: .zero))
  }
  
  private lazy var defaultLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.text = "@bible.ac.kr  "
    $0.textAlignment = .left
  }
  
  private lazy var haramButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "확인코드발송")
  }
  
  init(
    title: String,
    placeholder: String,
    options: RegisterTextFieldOptions = []
  ) {
    super.init(frame: .zero)
    configureUI(title: title, placeholder: placeholder, options: options)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    haramButton.rx.tap
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
  
  private func configureUI(title: String, placeholder: String, options: RegisterTextFieldOptions) {
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.black]
    )
    titleLabel.text = title
    
    [titleLabel, textField].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    if options.contains(.addButton) {
      addSubview(haramButton)
      textField.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        $0.leading.equalToSuperview()
        $0.height.equalTo(46)
      }
      
      haramButton.snp.makeConstraints {
        $0.leading.equalTo(textField.snp.trailing).offset(196 - 15 - 167)
        $0.centerY.equalTo(textField)
        $0.trailing.equalToSuperview()
        $0.height.equalTo(46)
        $0.width.equalTo(167)
      }
    } else {
      textField.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        $0.directionalHorizontalEdges.equalToSuperview()
        $0.height.equalTo(46)
      }
    }
    
    if options.contains(.defaultEmail) {
      textField.rightViewMode = .always
      textField.rightView = defaultLabel
    }
    
  }
}

struct RegisterTextFieldOptions: OptionSet {
  let rawValue: UInt
  
  static let defaultEmail = RegisterTextFieldOptions(rawValue: 1 << 0) // 디폴트 이메일
  static let addButton = RegisterTextFieldOptions(rawValue: 1 << 1) // 버튼 추가
}

extension Reactive where Base: RegisterTextField {
  var text: ControlProperty<String?> {
    return base.textField.rx.text
  }
}
