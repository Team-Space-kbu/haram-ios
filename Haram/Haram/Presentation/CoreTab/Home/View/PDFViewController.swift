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
    
    
    guard let pdfURL = self.pdfURL else { return }
    let document = PDFDocument(url: pdfURL)
    document?.delegate = self
    /// Set PDFView
    DispatchQueue.main.async {
      self.pdfView.document = document
//      document.document = PDFDocument(url: pdfURL)
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
  
  func documentDidEndDocumentFind(_ notification: Notification) {
    
  }
  
  func documentDidBeginDocumentFind(_ notification: Notification) {
    
  }
}

extension PDFViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
}
