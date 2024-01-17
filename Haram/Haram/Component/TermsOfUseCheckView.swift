//
//  TermsOfUseView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/02.
//

import UIKit

import SnapKit
import SkeletonView
import Then

enum TermsOfUseCheckViewType {
  
  /// 앱 정책 전체 동의를 위한 체크 뷰 타입
  case all
  
  /// 앱 정책 한가지 동의를 위한 체크 뷰 타입
  case none
}

struct TermsOfUseCheckViewModel {
  let policySeq: Int
  let content: String
  
  init(response: PolicyResponse) {
    policySeq = response.policySeq
    content = response.content
  }
}

final class TermsOfUseCheckView: UIView {
    
  // MARK: - Property
  
  private let type: TermsOfUseCheckViewType
  
  // MARK: - UI Components
  
  private let checkButton = UIButton().then {
    $0.setImage(UIImage(resource: .markBlack), for: .normal)
  }
  
  private let alertLabel = UILabel().then {
    $0.text = Constants.alertText
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.numberOfLines = 1
    $0.textAlignment = .center
  }
  
  private let termsLabel = PaddingLabel(withInsets: 4, 7, 6, 6).then {
    $0.backgroundColor = .hexF2F3F5
    $0.textColor = .hex545E6A
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.numberOfLines = 0
  }
  
  // MARK: - Initializations
  
  init(type: TermsOfUseCheckViewType = .none) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func configureUI() {
    isSkeletonable = true
    
    [checkButton, alertLabel].forEach { addSubview($0) }
    checkButton.snp.makeConstraints {
      $0.size.equalTo(18)
      $0.top.leading.equalToSuperview()
    }
    
    alertLabel.snp.makeConstraints {
      $0.leading.equalTo(checkButton.snp.trailing).offset(10)
      $0.trailing.lessThanOrEqualToSuperview()
      $0.directionalVerticalEdges.equalTo(checkButton)
    }
    
    if type == .none {
      addSubview(termsLabel)
      termsLabel.snp.makeConstraints {
        $0.top.equalTo(checkButton.snp.bottom).offset(10)
        $0.directionalHorizontalEdges.bottom.equalToSuperview()
      }
    }
  }
  
  func configureUI(with model: TermsOfUseCheckViewModel) {
    termsLabel.text = model.content
  }
  
  // MARK: - Constants
  
  enum Constants {
    static let alertText = "아래 약관에 모두 동의합니다."
  }
}
