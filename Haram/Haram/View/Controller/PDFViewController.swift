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

final class PDFViewController: BaseViewController {
  
  private let pdfURL: URL?
  
  private let pdfView = PDFView().then {
    $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    $0.autoScales = true
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
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    /// Set PDFView
    guard let pdfURL = pdfURL else { return }
    pdfView.document = PDFDocument(url: pdfURL)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(pdfView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    pdfView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}
