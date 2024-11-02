//
//  FindAccountViewHolder.swift
//  Haram
//
//  Created by 이건준 on 11/1/24.
//

import UIKit

import SnapKit
import Then

final class FindAccountViewHolder {
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 30, left: 15, bottom: 15, right: 15)
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 20
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "가입정보 찾기🔎"
    $0.textColor = .black
    $0.font = .bold24
  }
  private let descriptionLabel = UILabel().then {
    $0.text = "아이디또는 비밀번호를 찾는 방법을 선택해주세요\n진행과정은 가입된 이메일을 통해 정보를 찾습니다."
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.numberOfLines = 0
  }
  
  let findIDButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "아이디 정보 찾기"
    $0.configuration?.font = .bold13
    $0.configuration?.background.backgroundColor = .hex3B8686
    $0.configuration?.baseForegroundColor = .white
    $0.configuration?.background.cornerRadius = 10
  }
  let findPWDButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "비밀번호 정보 찾기"
    $0.configuration?.font = .bold13
    $0.configuration?.background.backgroundColor = .hex79BD9A
    $0.configuration?.baseForegroundColor = .white
    $0.configuration?.background.cornerRadius = 10
  }
  let backButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "돌아가기"
    $0.configuration?.font = .bold13
    $0.configuration?.baseBackgroundColor = .white
    $0.configuration?.baseForegroundColor = .hex898A8D
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.background.strokeWidth = 1
    $0.configuration?.background.strokeColor = .hex898A8D
  }
}

extension FindAccountViewHolder: ViewHolderType {
  func place(in view: UIView) {
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [titleLabel, descriptionLabel, findIDButton, findPWDButton, backButton].forEach { containerView.addArrangedSubview($0) }
  }
  
  func configureConstraints(for view: UIView) {
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    [findIDButton, findPWDButton, backButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(48)
      }
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    containerView.setCustomSpacing(35, after: descriptionLabel)
  }
}
