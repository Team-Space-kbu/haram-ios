//
//  NoticeDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit
import WebKit

import SnapKit
import SkeletonView
import Then

struct NoticeDetailModel {
  let title: String
  let writerInfo: String
  let content: String
}

final class NoticeDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: NoticeDetailViewModelType
  private let path: String
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 11
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 34, left: 15, bottom: 15, right: 15)
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold16
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let writerInfoLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
  }
  
  private let configuration = WKWebViewConfiguration().then {
    let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
    $0.preferences = preferences
  }
  
  
  private lazy var webView = WKWebView(frame: .zero, configuration: configuration).then {
    $0.scrollView.showsVerticalScrollIndicator = false
    $0.scrollView.showsHorizontalScrollIndicator = false
    $0.scrollView.bounces = false
    $0.navigationDelegate = self
  }
  
  init(path: String, viewModel: NoticeDetailViewModelType = NoticeDetailViewModel()) {
    self.viewModel = viewModel
    self.path = path
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    _ = [scrollView, containerView, titleLabel, writerInfoLabel, webView].map { $0.isSkeletonable = true }
    setupSkeletonView()
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireNoticeDetailInfo(path: path)
    
    viewModel.noticeDetailModel
      .drive(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.webView.loadHTMLString(model.content, baseURL: nil)
        owner.titleLabel.text = model.title
        owner.writerInfoLabel.text = model.writerInfo
      }
      .disposed(by: disposeBag)
    
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [titleLabel, writerInfoLabel, webView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    webView.snp.makeConstraints {
      $0.height.equalTo(webView.scrollView.contentSize.height)
    }
    
    containerView.setCustomSpacing(16, after: writerInfoLabel)
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension NoticeDetailViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.evaluateJavaScript("document.readyState") { complete, error in
      if complete != nil {
        webView.evaluateJavaScript("document.body.scrollHeight") { height, error in
          webView.snp.updateConstraints {
            $0.height.equalTo(height as! CGFloat)
          }
        }
      }
    }
  }
}
