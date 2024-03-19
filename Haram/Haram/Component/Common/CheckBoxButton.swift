//
//  CheckBoxButton.swift
//  Haram
//
//  Created by 이건준 on 3/9/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class CheckBoxButton: UIButton {
  
  // MARK: - Property
  
  private let checkStyle: ButtonType
  
  private let disposeBag = DisposeBag()
  
  /// 체크가 되어있다면 `true`, 아니면 `false`를 리턴합니다.
  var isChecked = false {
    willSet {
      UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve) {
        switch self.checkStyle {
        case .full:
          self.backgroundColor    = newValue ? .hex3B8686 : .lightGray
          self.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
        case .none:
          self.backgroundColor    = newValue ? .white : .white
          self.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
          
          // 체크모양 이미지 설정
          newValue ? self.setImage(Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal), for: .normal) : self.setImage(nil, for: .normal)
        }
      }
    }
  }
  
  // MARK: - Init
  
  init(type: ButtonType) {
    self.checkStyle = type
    super.init(frame: .zero)
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStyles() {
    self.layer.cornerRadius = 3
    switch checkStyle {
    case .full:
      self.setImage(Image.checkShape?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
      self.backgroundColor = .lightGray
      self.layer.borderColor = UIColor.lightGray.cgColor
      self.layer.borderWidth = 2
    case .none:
      self.backgroundColor = .white
      self.layer.borderWidth = 2
      self.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
  
  private func bind() {
    self.rx.tap
      .bind { [weak self] in
        self?.isChecked.toggle()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Enum

extension CheckBoxButton {
  enum ButtonType {
    
    /// 체크되어있지 않을 때 비어있는 칸으로 보입니다.
    case none
    
    /// 체크되어있지 않을 때 회색의 체크표시 모양이 보입니다.
    case full
  }
}

extension CheckBoxButton {
  private enum Image {
    static let checkShape = UIImage(systemName: "checkmark.square.fill")
  }
}

// MARK: - RxSwift Custom Property

extension Reactive where Base: CheckBoxButton {
  
  var isChecked: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .touchUpInside) { checkbox in
      checkbox.isChecked
    } setter: { checkbox, value in
      if checkbox.isChecked != value {
        checkbox.isChecked = value
      }
    }
  }
}

final class CheckBoxControl: UIControl {
  
  // MARK: - Property
  
  private let checkStyle: ButtonType
  
  private let disposeBag = DisposeBag()
  
  private let checkImage = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 3
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.textAlignment = .left
  }
  
  /// 체크가 되어있다면 `true`, 아니면 `false`를 리턴합니다.
  var isChecked = false {
    willSet {
      UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve) {
        switch self.checkStyle {
        case .full:
          self.checkImage.backgroundColor    = newValue ? .hex3B8686 : .lightGray
          self.checkImage.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
        case .none:
          self.checkImage.backgroundColor    = newValue ? .white : .white
          self.checkImage.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
          
          // 체크모양 이미지 설정
          self.checkImage.image = newValue ? Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal) :  nil
        }
      }
    }
  }
  
  // MARK: - Init
  
  init(type: ButtonType, title: String) {
    self.checkStyle = type
    super.init(frame: .zero)
    alertLabel.text = title
    setupStyles()
    bind()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    _ = [checkImage, alertLabel].map { addSubview($0) }
  }
  
  private func setupConstraints() {
    checkImage.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    alertLabel.snp.makeConstraints {
      $0.centerY.equalTo(checkImage)
      $0.leading.equalTo(checkImage.snp.trailing).offset(5)
      $0.trailing.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    switch checkStyle {
    case .full:
      self.checkImage.image = Image.checkShape?.withTintColor(.white, renderingMode: .alwaysOriginal)
      self.checkImage.backgroundColor = .lightGray
      self.checkImage.layer.borderColor = UIColor.lightGray.cgColor
      self.checkImage.layer.borderWidth = 2
    case .none:
      self.checkImage.backgroundColor = .white
      self.checkImage.layer.borderWidth = 2
      self.checkImage.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
  
  private func bind() {
    self.rx.controlEvent(.touchUpInside)
      .bind { [weak self] in
        self?.isChecked.toggle()
      }
      .disposed(by: disposeBag)
  }
  
  func setTitle(_ title: String) {
    alertLabel.text = title
  }
}

// MARK: - Enum

extension CheckBoxControl {
  enum ButtonType {
    
    /// 체크되어있지 않을 때 비어있는 칸으로 보입니다.
    case none
    
    /// 체크되어있지 않을 때 회색의 체크표시 모양이 보입니다.
    case full
  }
}

extension CheckBoxControl {
  private enum Image {
    static let checkShape = UIImage(systemName: "checkmark.square.fill")
  }
}

// MARK: - RxSwift Custom Property

extension Reactive where Base: CheckBoxControl {
  
  var isChecked: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .touchUpInside) { checkbox in
      checkbox.isChecked
    } setter: { checkbox, value in
      if checkbox.isChecked != value {
        checkbox.isChecked = value
      }
    }
  }
}
