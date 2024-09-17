//
//  TermsOfUseTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import UIKit
import WebKit

import RxSwift
import SnapKit
import SkeletonView
import Then

struct TermsOfUseTableViewCellModel {
  let seq: Int
  let title: String
  var isChecked: Bool
  let isRequired: Bool
  let content: String
  
  init(response: InquireTermsSignUpResponse) {
    seq = response.termsSeq
    title = response.title
    isChecked = false
    isRequired = response.isRequired
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
  
  init(response: PolicyResponse) {
    seq = response.policySeq
    title = response.title
    isChecked = false
    isRequired = response.isRequired
    content = "<style>body{background-color:#F2F3F5;padding-top: 4px;padding-right: 6px;padding-bottom: 7px;padding-left: 6px;}</style>" + response.content
  }
}

final class TermsOfUseTableViewCell: UITableViewCell, ReusableView {
  
  private var seq: Int?
  private var isChecked = false {
    willSet {
      UIView.transition(with: checkImage, duration: 0.15, options: .transitionCrossDissolve) {
        self.checkImage.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
        self.checkImage.image = newValue ? Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal) :  nil
      }
    }
  }
  
  private let checkImage = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 3
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 3
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.textAlignment = .left
    $0.isSkeletonable = true
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
    seq = nil
    alertLabel.text = nil
    isChecked = false
    checkImage.backgroundColor = nil
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    selectionStyle = .none
    self.checkImage.backgroundColor = .white
    self.checkImage.layer.borderWidth = 2
    self.checkImage.layer.borderColor = UIColor.lightGray.cgColor
    
    _ = [checkImage, alertLabel, webView].map { contentView.addSubview($0) }
    
    checkImage.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    alertLabel.snp.makeConstraints {
      $0.centerY.equalTo(checkImage)
      $0.leading.equalTo(checkImage.snp.trailing).offset(5)
      $0.trailing.equalToSuperview()
    }
    
    webView.snp.makeConstraints {
      $0.top.equalTo(checkImage.snp.bottom).offset(10)
      $0.height.equalTo(124)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(21)
    }
  }
  
  func configureUI(with model: TermsOfUseTableViewCellModel) {
    alertLabel.text = model.title
    self.isChecked = model.isChecked
    seq = model.seq
    webView.loadHTMLString(model.content, baseURL: nil)
  }
  
  private enum Image {
    static let checkShape = UIImage(systemName: "checkmark.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))
  }
}
