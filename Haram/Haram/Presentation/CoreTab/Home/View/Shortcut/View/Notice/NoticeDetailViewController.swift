//
//  NoticeDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import SnapKit
import Then

final class NoticeDetailViewController: BaseViewController, BackButtonHandler {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 11
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 34, left: 15, bottom: .zero, right: 15)
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
    $0.text = "공지사항 제목"
  }
  
  private let writerInfoLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
    $0.text = "2022-12-28|이건준"
  }
  
  private let contentLabel = UILabel().then {
    $0.font = .regular15
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.text = "공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용공지사항내용"
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
    [titleLabel, writerInfoLabel, contentLabel].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    containerView.setCustomSpacing(16, after: writerInfoLabel)
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
