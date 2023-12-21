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
  
  // MARK: - Property
  
  private let viewModel: BibleSearchResultViewModelType
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 21
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 25, left: 15, bottom: 15, right: 15)
  }
  
  private let bibleTitleView = BibleTitleView()
  
  private let contentLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.textAlignment = .justified
  }
  
  // MARK: - Initializations
  
  init(
    viewModel: BibleSearchResultViewModelType = BibleSearchResultViewModel(),
    request: InquireChapterToBibleRequest
  ) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    bind(request: request)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  func bind(request: InquireChapterToBibleRequest) {
    super.bind()
    viewModel.whichRequestForSearch.onNext(request)
    
    viewModel.searchResultContent
      .drive(with: self) { owner, content in
        owner.contentLabel.addLineSpacing(lineSpacing: 15, string: content)
      }
      .disposed(by: disposeBag)
    
    bibleTitleView.configureUI(with: .init(
      title: request.book,
      chapter: "\(request.chapter)"
    ))
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
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
      $0.height.equalTo(39)
    }
    
  }
  
  // MARK: - Action Function
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

