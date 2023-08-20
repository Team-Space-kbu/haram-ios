//
//  BibleSearchResultViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

final class BibleSearchResultViewController: BaseViewController {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 21
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private let bibleTitleView = BibleTitleView()
  
  private let contentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "성경"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    bibleTitleView.configureUI(with: .init(title: "마태복음", chapter: "2장"))
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 15

    let attributedString = NSAttributedString(string:"성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용성경내용", attributes: [.paragraphStyle: paragraphStyle])
    contentLabel.attributedText = attributedString
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [bibleTitleView, contentLabel].forEach { containerView.addArrangedSubview($0) }
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
    
    bibleTitleView.snp.makeConstraints {
//      $0.top.equalTo(view.safeAreaLayoutGuide)
//      $0.leading.equalToSuperview().inset(15)
      $0.height.equalTo(39)
    }
    
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

struct BibleTitleViewModel {
  let title: String
  let chapter: String
}

final class BibleTitleView: UIView {
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hex1A1E27
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold24
  }
  
  private let chapterLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.font = .regular20
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [lineView, titleLabel, chapterLabel].forEach { addSubview($0) }
    lineView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.width.equalTo(3)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(lineView.snp.trailing).offset(5)
      $0.centerY.equalToSuperview()
    }
    
    chapterLabel.snp.makeConstraints {
      $0.leading.equalTo(titleLabel.snp.trailing)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: BibleTitleViewModel) {
    titleLabel.text = model.title
    chapterLabel.text = model.chapter
  }
}
