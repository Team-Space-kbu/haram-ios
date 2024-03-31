//
//  HaramProvisionViewController.swift
//  Haram
//
//  Created by 이건준 on 3/30/24.
//

import UIKit
import WebKit

import SnapKit
import Then

final class HaramProvisionViewController: BaseViewController, BackButtonHandler {
  
  private let url: URL?
  
  private let provisionWebView = WKWebView()
  
  private let indicatorView = UIActivityIndicatorView(style: .large).then {
    $0.startAnimating()
  }
  
  init(url: URL?) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(provisionWebView)
    view.addSubview(indicatorView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    provisionWebView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupBackButton()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    provisionWebView.navigationDelegate = self
    
    guard NetworkManager.shared.isConnected else {
      AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: self) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
        self.navigationController?.popViewController(animated: true)
      }
      return
    }
    
    guard let url = self.url else { return }
    let request = URLRequest(url: url)
    provisionWebView.load(request)
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension HaramProvisionViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
}

extension HaramProvisionViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    indicatorView.stopAnimating()
  }
}
