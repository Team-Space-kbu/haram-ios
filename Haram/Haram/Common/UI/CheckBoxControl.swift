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

final class CheckBoxControl: UIControl {
  
  // MARK: - Property
  
  private let checkStyle: ButtonType
  private var title: String?
  
  /// 체크가 되어있다면 `true`, 아니면 `false`를 리턴합니다.
  var isChecked = false {
    willSet {
      updateUI(isChecked: newValue)
    }
  }
  
  private let checkImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 3
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.textAlignment = .left
  }
  
  // MARK: - Init
  
  init(type: ButtonType, title: String? = nil) {
    self.checkStyle = type
    self.title = title
    super.init(frame: .zero)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    addSubview(checkImageView)
    if let _ = title {
      addSubview(alertLabel)
    }
  }
  
  private func setupConstraints() {
    checkImageView.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    if let _ = title {
      alertLabel.snp.makeConstraints {
        $0.centerY.equalTo(checkImageView)
        $0.leading.equalTo(checkImageView.snp.trailing).offset(5)
        $0.trailing.equalToSuperview()
      }
    }
  }
  
  private func setupStyles() {
    alertLabel.text = title
    
    switch checkStyle {
    case .full:
      configureUI(
        image: Image.checkShape?.withTintColor(.white, renderingMode: .alwaysOriginal),
        backgroundColor: .lightGray,
        borderColor: UIColor.lightGray.cgColor,
        borderWidth: 2
      )
    case .none:
      configureUI(
        image: nil,
        backgroundColor: .white,
        borderColor: UIColor.lightGray.cgColor,
        borderWidth: 2
      )
    }
  }
}

extension CheckBoxControl {
  private func updateUI(isChecked: Bool) {
    UIView.transition(with: checkImageView, duration: 0.15, options: .transitionCrossDissolve) {
      let image = isChecked ? Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal) :  nil
      
      switch self.checkStyle {
      case .full:
        self.configureUI(
          image: image,
          backgroundColor: isChecked ? .hex3B8686 : .lightGray,
          borderColor: isChecked ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor,
          borderWidth: 2
        )
      case .none:
        self.configureUI(
          image: image,
          backgroundColor: .white,
          borderColor: isChecked ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor,
          borderWidth: 2
        )
      }
    }
  }
  
  private func configureUI(
    image: UIImage?,
    backgroundColor: UIColor,
    borderColor: CGColor,
    borderWidth: CGFloat
  ) {
    checkImageView.image = image
    checkImageView.backgroundColor = backgroundColor
    checkImageView.layer.borderColor = borderColor
    checkImageView.layer.borderWidth = borderWidth
  }
  
  func setTitle(_ title: String) {
    if !subviews.contains(alertLabel) {
      addSubview(alertLabel)
      alertLabel.snp.makeConstraints {
        $0.centerY.equalTo(checkImageView)
        $0.leading.equalTo(checkImageView.snp.trailing).offset(5)
        $0.trailing.equalToSuperview()
      }
    }
    alertLabel.text = title
  }
  
  func initializeUI() {
    checkImageView.image = nil
    checkImageView.backgroundColor = nil
    checkImageView.layer.borderColor = nil
    alertLabel.text = nil
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
