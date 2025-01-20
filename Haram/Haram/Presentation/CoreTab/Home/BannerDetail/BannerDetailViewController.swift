//
//  HomeBannerDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit
import WebKit

import RxSwift
import SkeletonView
import SnapKit
import Then

final class BannerDetailViewController: BaseViewController {
  
  private let viewModel: HomeBannerDetailViewModel
  private var bannerModel: [HomebannerCollectionViewCellModel] = []
  
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
  
  init(viewModel: HomeBannerDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    let input = HomeBannerDetailViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    
    output.bannerInfo
      .subscribe(with: self) { owner, result in
        let (title, content, writerInfo) = result
        owner.view.hideSkeleton()
        
        owner.webView.loadHTMLString(content, baseURL: nil)
        owner.titleLabel.text = title
        owner.writerInfoLabel.text = writerInfo
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        }
      }
      .disposed(by: disposeBag)
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
  
  override func setupStyles() {
    super.setupStyles()
    
    _ = [scrollView, containerView, titleLabel, writerInfoLabel, webView].map { $0.isSkeletonable = true }
    
    setupSkeletonView()
    setupBackButton()
  }
}

extension BannerDetailViewController {
  private func bindNotificationCenter(input: HomeBannerDetailViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension BannerDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension BannerDetailViewController: WKNavigationDelegate {
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
