//
//  TermsOfUseView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/02.
//

import UIKit

import RxSwift
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
  var isChecked: Bool
  let policySeq: Int
  let title: String
  let content: String
  
  init(response: PolicyResponse) {
    isChecked = false
    title = response.title
    policySeq = response.policySeq
    content = response.content
  }
}

protocol TermsOfUseCheckViewDelegate: AnyObject {
  func didTappedCheckBox(policySeq: Int, isChecked: Bool)
}

final class TermsOfUseCheckView: UIView {
    
  // MARK: - Property
  
  weak var delegate: TermsOfUseCheckViewDelegate?
  private let type: TermsOfUseCheckViewType
  private var policySeq: Int?
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let checkBoxControl = CheckBoxControl(type: .none, title: Constants.alertText)
  
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
    $0.font = .regular10
  }
  
  // MARK: - Initializations
  
  init(type: TermsOfUseCheckViewType = .none) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func bind() {
    checkBoxControl.rx.isChecked
      .subscribe(with: self) { owner, isChecked in
        guard let policySeq = owner.policySeq else { return }
        owner.delegate?.didTappedCheckBox(policySeq: policySeq, isChecked: isChecked)
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    isSkeletonable = true
    addSubview(checkBoxControl)
//    [checkButton, alertLabel].forEach { addSubview($0) }
    checkBoxControl.snp.makeConstraints {
      $0.size.equalTo(18)
      $0.top.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    
//    alertLabel.snp.makeConstraints {
//      $0.leading.equalTo(checkButton.snp.trailing).offset(10)
//      $0.trailing.lessThanOrEqualToSuperview()
//      $0.centerY.equalTo(checkButton)
//    }
    
    if type == .none {
      addSubview(termsLabel)
      termsLabel.snp.makeConstraints {
        $0.top.equalTo(checkBoxControl.snp.bottom).offset(10)
        $0.directionalHorizontalEdges.bottom.equalToSuperview()
      }
    }
  }
  
  func configureUI(with model: TermsOfUseCheckViewModel) {
    termsLabel.addLineSpacing(lineSpacing: 7, string: model.content)
    checkBoxControl.setTitle(model.title)
//    alertLabel.text = model.title
    self.policySeq = model.policySeq
  }
  
  // MARK: - Constants
  
  enum Constants {
    static let alertText = "아래 약관에 모두 동의합니다."
  }
}
