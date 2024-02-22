//
//  NoticeDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit
import WebKit

import SnapKit
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
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 11
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 34, left: 15, bottom: 15, right: 15)
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
  }
  
  private let writerInfoLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
  }
  
  private let webView = WKWebView()
  
  init(path: String, viewModel: NoticeDetailViewModelType = NoticeDetailViewModel()) {
    self.viewModel = viewModel
    self.path = path
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireNoticeDetailInfo(path: path)
    
    viewModel.noticeDetailModel
      .drive(with: self) { owner, model in
        owner.titleLabel.text = model.title
        owner.writerInfoLabel.text = model.writerInfo
        owner.webView.loadHTMLString(model.content, baseURL: nil)
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
      $0.top.directionalHorizontalEdges.width.equalToSuperview()
      $0.height.greaterThanOrEqualToSuperview()
    }
    
    containerView.setCustomSpacing(16, after: writerInfoLabel)
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
