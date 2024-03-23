//
//  TermsWebTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 3/21/24.
//

import UIKit
import WebKit

import SnapKit
import Then

struct TermsWebTableViewCellModel {
  let seq: Int
  let content: String
  
  init(response: InquireTermsSignUpResponse) {
    seq = response.termsSeq
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
}

final class TermsWebTableViewCell: UITableViewCell {
  
  static let identifier = "TermsWebTableViewCell"
  
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
    
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    selectionStyle = .none
    
    contentView.addSubview(webView)
    webView.snp.makeConstraints {
      $0.height.equalTo(124)
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(21)
    }
  }
  
  func configureUI(with model: TermsWebTableViewCellModel) {
    webView.loadHTMLString(model.content, baseURL: nil)
  }
}
