//
//  HomeNoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SnapKit
import Then

final class HomeNoticeViewController: BaseViewController, BackButtonHandler {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = true
    $0.isSkeletonable = true
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: 15, right: 15)
    $0.isSkeletonable = true
    $0.spacing = 10
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.font = .regular18
    $0.textAlignment = .left
  }
  
  init(title: String, content: String) {
    titleLabel.text = title
    contentLabel.text = content
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    _ = [titleLabel, contentLabel].map { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(27)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension HomeNoticeViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

