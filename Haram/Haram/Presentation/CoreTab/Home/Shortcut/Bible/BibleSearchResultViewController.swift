//
//  BibleSearchResultViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class BibleSearchResultViewController: BaseViewController, BackButtonHandler {
  
  // MARK: - Property
  
  private let viewModel: BibleSearchResultViewModelType
  private let request: InquireChapterToBibleRequest
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 21
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
    $0.isSkeletonable = true
  }
  
  private let bibleTitleView = BibleTitleView()
  
  private let contentLabel = UILabel().then {
    $0.font = .regular18
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.textAlignment = .justified
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 30
  }
  
  // MARK: - Initializations
  
  init(
    viewModel: BibleSearchResultViewModelType = BibleSearchResultViewModel(),
    request: InquireChapterToBibleRequest
  ) {
    self.viewModel = viewModel
    self.request = request
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    viewModel.searchBible(request: request)
    
    viewModel.searchResultContent
      .drive(with: self) { owner, content in
        owner.view.hideSkeleton()
        owner.contentLabel.addLineSpacing(lineSpacing: 15, string: content)
      }
      .disposed(by: disposeBag)
    
    bibleTitleView.configureUI(with: .init(
      title: request.book,
      chapter: "\(request.chapter)"
    ))
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    registerNotifications()
    setupBackButton()
    setupSkeletonView()
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
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension BibleSearchResultViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.searchBible(request: request)
  }
}
