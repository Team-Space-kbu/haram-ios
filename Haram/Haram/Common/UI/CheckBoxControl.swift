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
    static let checkShape = UIImage(systemName: "checkmark.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))
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
  
  private let checkImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 3
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 3
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  /// 체크가 되어있다면 `true`, 아니면 `false`를 리턴합니다.
  var isChecked = false {
    willSet {
      UIView.transition(with: checkImageView, duration: 0.15, options: .transitionCrossDissolve) {
        switch self.checkStyle {
        case .full:
          self.checkImageView.backgroundColor    = newValue ? .hex3B8686 : .lightGray
          self.checkImageView.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
        case .none:
          self.checkImageView.backgroundColor    = newValue ? .white : .white
          self.checkImageView.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
          
          // 체크모양 이미지 설정
          self.checkImageView.image = newValue ? Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal) :  nil
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
    _ = [checkImageView, alertLabel].map { addSubview($0) }
  }
  
  private func setupConstraints() {
    checkImageView.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    alertLabel.snp.makeConstraints {
      $0.centerY.equalTo(checkImageView)
      $0.leading.equalTo(checkImageView.snp.trailing).offset(5)
      $0.trailing.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    switch checkStyle {
    case .full:
      self.checkImageView.image = Image.checkShape?.withTintColor(.white, renderingMode: .alwaysOriginal)
      self.checkImageView.backgroundColor = .lightGray
      self.checkImageView.layer.borderColor = UIColor.lightGray.cgColor
      self.checkImageView.layer.borderWidth = 2
    case .none:
      self.checkImageView.image = nil
      self.checkImageView.backgroundColor = .white
      self.checkImageView.layer.borderWidth = 2
      self.checkImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
  
  private func bind() {
    self.rx.controlEvent(.touchUpInside)
      .bind { [weak self] in
//        self?.isChecked.toggle()
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
    static let checkShape = UIImage(systemName: "checkmark.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))
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
