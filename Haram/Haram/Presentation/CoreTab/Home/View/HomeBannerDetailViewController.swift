//
//  HomeBannerDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SnapKit
import Then

final class HomeBannerDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: HomeBannerDetailViewModelType
  private let bannerSeq: Int
  
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
    $0.spacing = 5
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold16
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.font = .regular14
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 5
  }
  
  init(bannerSeq: Int, viewModel: HomeBannerDetailViewModelType = HomeBannerDetailViewModel()) {
    self.viewModel = viewModel
    self.bannerSeq = bannerSeq
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireBannerInfo(bannerSeq: bannerSeq)
    
    viewModel.bannerInfo
      .emit(with: self) { owner, result in
        let (title, content) = result
        owner.view.hideSkeleton()
    
        owner.titleLabel.text = title
        owner.contentLabel.text = content
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터 연결 후 다시 시도해주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
          owner.navigationController?.popViewController(animated: true)
        }
      }
      .disposed(by: disposeBag)
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
    setupSkeletonView()
    setupBackButton()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension HomeBannerDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
