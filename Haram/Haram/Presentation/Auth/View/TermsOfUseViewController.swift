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
    $0.font = .bold24
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.backgroundColor = .clear
    $0.spacing = 21
  }
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
    $0.backgroundColor = .clear
  }
  
  private let cancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "취소", contentInsets: .zero)
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "확인", contentInsets: .zero)
  }
  
  private let checkAllButton = TermsOfUseCheckView(type: .all)
  private let checkButton = TermsOfUseCheckView()
  private let checkButton1 = TermsOfUseCheckView()
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
  }
  
  override func bind() {
    super.bind()
    applyButton.rx.tap
      .subscribe(with: self) { owner, _ in
        let vc = VerifyEmailViewController()
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
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [cancelButton, applyButton].forEach { horizontalStackView.addArrangedSubview($0) }
    [titleLabel, checkAllButton, checkButton, checkButton1, horizontalStackView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    checkAllButton.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    [checkButton, checkButton1].forEach {
      $0.snp.makeConstraints {
        $0.height.greaterThanOrEqualTo(18)
      }
    }
    
    containerView.setCustomSpacing(23, after: titleLabel)
    containerView.setCustomSpacing(35, after: checkAllButton)
    containerView.setCustomSpacing(26, after: checkButton)
  }
}
