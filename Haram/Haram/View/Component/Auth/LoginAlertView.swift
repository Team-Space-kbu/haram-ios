//
//  LoginAlertView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol LoginAlertViewDelegate: AnyObject {
  func didTappedRegisterButton()
}

final class LoginAlertView: UIView {
  
  weak var delegate: LoginAlertViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.alignment = .center
  }
  
  private let alertLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular13
    $0.text = "아직 회원가입하지 않았나요?"
  }
  
  private let registerButton = UIButton().then {
    $0.setTitleColor(.hex3B8686, for: .normal)
    $0.setTitle("회원가입", for: .normal)
    $0.titleLabel?.font = .bold13
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    registerButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedRegisterButton()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    addSubview(containerView)
    [alertLabel, registerButton].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    alertLabel.snp.makeConstraints {
      $0.width.equalTo(156)
    }
    
    registerButton.snp.makeConstraints {
      $0.width.equalTo(48)
    }
  }
}
