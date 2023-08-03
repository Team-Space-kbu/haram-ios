//
//  TermsOfUseViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/07/23.
//

import UIKit

import SnapKit
import Then

final class TermsOfUseViewController: BaseViewController {
  
  private let titleLabel = UILabel().then {
    $0.text = "이용약관📄"
    $0.textColor = .black
    $0.font = .bold
    $0.font = .systemFont(ofSize: 24)
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 101 - 35, left: 15, bottom: .zero, right: 15)
    $0.backgroundColor = .clear
  }
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
  }
  
  private let cancelButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "취소")
  }
  
  private let applyButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "확인")
  }
  
  private let checkButton = TermsOfUseCheckView()
  
  override func bind() {
    super.bind()
    applyButton.rx.tap
      .subscribe(with: self) { owner, _ in
        let vc = RegisterViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    view.addSubview(horizontalStackView)
    [titleLabel, checkButton].forEach { containerView.addArrangedSubview($0) }
    [cancelButton, applyButton].forEach { horizontalStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(49)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    checkButton.snp.makeConstraints {
      $0.height.equalTo(400)
    }
  }
}
