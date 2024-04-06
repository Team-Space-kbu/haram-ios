//
//  PDFViewController.swift
//  Haram
//
//  Created by 이건준 on 11/17/23.
//

import UIKit

import PDFKit
import SnapKit
import Then

final class PDFViewController: BaseViewController, BackButtonHandler, PDFDocumentDelegate {
  
  private let pdfURL: URL?
  
  private let pdfView = PDFView().then {
    $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    $0.autoScales = true
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large).then {
    $0.startAnimating()
  }
  
  init(pdfURL: URL?) {
    self.pdfURL = pdfURL
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set Navigationbar
    setupBackButton()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
   
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
    
    guard let pdfURL = self.pdfURL else { return }
  
    /// Set PDFView
    DispatchQueue.main.async {
      self.pdfView.document = PDFDocument(url: pdfURL)
      self.indicatorView.stopAnimating()
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(pdfView)
    view.addSubview(indicatorView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    pdfView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension PDFViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
