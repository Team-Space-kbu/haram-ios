//
//  TermsOfUseTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import UIKit
import WebKit

import RxSwift
import SnapKit
import SkeletonView
import Then

struct TermsOfUseTableViewCellModel {
  let seq: Int
  let title: String
  var isChecked: Bool
  let isRequired: Bool
  let content: String
  
  init(response: InquireTermsSignUpResponse) {
    seq = response.termsSeq
    title = response.title
    isChecked = false
    isRequired = response.isRequired
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
  
  init(response: PolicyResponse) {
    seq = response.policySeq
    title = response.title
    isChecked = false
    isRequired = response.isRequired
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
}

final class TermsOfUseTableViewCell: UITableViewCell, ReusableView {
  let checkboxControl = CheckBoxControl(type: .none).then {
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
    $0.skeletonCornerRadius = 10
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    checkboxControl.initializeUI()
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    selectionStyle = .none
    
    _ = [checkboxControl, webView].map { contentView.addSubview($0) }
    
    checkboxControl.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalToSuperview()
      $0.height.equalTo(18)
    }
    
    webView.snp.makeConstraints {
      $0.top.equalTo(checkboxControl.snp.bottom).offset(10)
      $0.height.equalTo(124)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(21)
    }
  }
  
  func configureUI(with model: TermsOfUseTableViewCellModel) {
    checkboxControl.setTitle(model.title)
    checkboxControl.isChecked = model.isChecked
    webView.loadHTMLString(model.content, baseURL: nil)
  }
}
