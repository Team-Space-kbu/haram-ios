//
//  TermsOfUseView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/02.
//

import UIKit
import WebKit

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
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
  
  init(response: InquireTermsSignUpResponse) {
    isChecked = false
    title = response.title
    policySeq = response.termsSeq
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
}

protocol TermsOfUseCheckViewDelegate: AnyObject {
  func didTappedCheckBox(policySeq: Int, isChecked: Bool)
  func didTappedAll(isChecked: Bool)
}

extension TermsOfUseCheckViewDelegate {
  func didTappedAll(isChecked: Bool) {}
}

final class TermsOfUseCheckView: UIView {
    
  // MARK: - Property
  
  weak var delegate: TermsOfUseCheckViewDelegate?
  private let type: TermsOfUseCheckViewType
  private var policySeq: Int?
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let checkBoxControl = CheckBoxControl(type: .none, title: Constants.alertText).then {
    $0.isSkeletonable = true
  }
  
  private let configuration = WKWebViewConfiguration().then {
    let preferences = WKPreferences()
    WKWebpagePreferences().allowsContentJavaScript = true
    preferences.javaScriptCanOpenWindowsAutomatically = true
    $0.preferences = preferences
  }
  
  
  private lazy var webView = WKWebView(frame: .zero, configuration: configuration).then {
    $0.scrollView.showsVerticalScrollIndicator = false
    $0.scrollView.showsHorizontalScrollIndicator = false
    $0.scrollView.backgroundColor = .hexF2F3F5
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
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
        if owner.type == .all {
          owner.delegate?.didTappedAll(isChecked: isChecked)
        } else {
          guard let policySeq = owner.policySeq else { return }
          owner.delegate?.didTappedCheckBox(policySeq: policySeq, isChecked: isChecked)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    isSkeletonable = true
    addSubview(checkBoxControl)
    checkBoxControl.snp.makeConstraints {
      $0.size.equalTo(18 + 10)
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    if type == .none {
      addSubview(webView)
      webView.snp.makeConstraints {
        $0.top.equalTo(checkBoxControl.snp.bottom)
        $0.directionalHorizontalEdges.equalToSuperview()
        $0.bottom.lessThanOrEqualToSuperview()
        $0.height.equalTo(124)
      }
    }
  }
  
  func configureUI(with model: TermsOfUseCheckViewModel) {
    webView.loadHTMLString(model.content, baseURL: nil)
    checkBoxControl.setTitle(model.title)
    self.policySeq = model.policySeq
  }
  
  func configureUI(isChecked: Bool) {
    checkBoxControl.isChecked = isChecked
  }
  
  // MARK: - Constants
  
  enum Constants {
    static let alertText = "아래 약관에 모두 동의합니다."
  }
}
