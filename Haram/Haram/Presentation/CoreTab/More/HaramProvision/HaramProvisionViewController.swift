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

final class HaramProvisionViewController: BaseViewController {
  
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
  
  override func bind() {
    super.bind()
    navigationItem.leftBarButtonItem!.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [provisionWebView, indicatorView].forEach { view.addSubview($0) }
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
    provisionWebView.navigationDelegate = self
    
    guard NetworkManager.shared.isConnected else {
      AlertManager.showAlert(on: self.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
        self.navigationController?.popViewController(animated: true)
      })
      return
    }
    
    guard let url = self.url else { return }
    let request = URLRequest(url: url)
    provisionWebView.load(request)
  }
}

extension HaramProvisionViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension HaramProvisionViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    indicatorView.stopAnimating()
  }
}
