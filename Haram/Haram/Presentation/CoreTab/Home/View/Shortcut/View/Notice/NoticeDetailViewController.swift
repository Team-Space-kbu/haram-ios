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
  
  // MARK: - Property
  
  private let viewModel: NoticeDetailViewModel
  
  // MARK: - UI Components
  
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
    WKWebpagePreferences().allowsContentJavaScript = true
    preferences.javaScriptCanOpenWindowsAutomatically = true
    $0.preferences = preferences
  }
  
  
  private lazy var webView = WKWebView(frame: .zero, configuration: configuration).then {
    $0.scrollView.showsVerticalScrollIndicator = false
    $0.scrollView.showsHorizontalScrollIndicator = false
    $0.scrollView.bounces = false
    $0.navigationDelegate = self
  }
  
  // MARK: - Initializations
  
  init(viewModel: NoticeDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    let input = NoticeDetailViewModel.Input(viewDidLoad: .just(()))
    let output = viewModel.transform(input: input)
    
    output.noticeDetailModelRelay
      .asDriver(onErrorDriveWith: .empty())
      .drive(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.webView.loadHTMLString(model.content, baseURL: nil)
        owner.titleLabel.text = model.title
        owner.writerInfoLabel.text = model.writerInfo
      }
      .disposed(by: disposeBag)
    
    output.errorMessageRelay
      .asSignal()
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
    
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
//    registerNotifications()
    setupBackButton()
    _ = [scrollView, containerView, titleLabel, writerInfoLabel, webView].map { $0.isSkeletonable = true }
    setupSkeletonView()
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
      $0.height.equalTo(UIScreen.main.bounds.height)
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
          if let height = height as? CGFloat {
            webView.snp.updateConstraints {
              $0.height.equalTo(height)
            }
          } else {
            // height 변환에 실패한 경우
            print("Error converting height: \(String(describing: error))")
          }
        }
      }
    }
  }
}

//extension NoticeDetailViewController {
//  private func registerNotifications() {
//    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
//  }
//  
//  private func removeNotifications() {
//    NotificationCenter.default.removeObserver(self)
//  }
//  
//  @objc
//  private func refreshWhenNetworkConnected() {
//    viewModel.inquireNoticeDetailInfo(type: type, path: path)
//  }
//}
