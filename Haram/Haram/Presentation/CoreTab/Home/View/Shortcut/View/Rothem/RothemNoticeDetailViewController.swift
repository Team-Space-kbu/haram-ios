//
//  RothemNoticeDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class RothemNoticeDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: RothemNoticeDetailViewModelType
  private let noticeSeq: Int
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = true
    $0.isSkeletonable = true
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: 15, right: 15)
    $0.isSkeletonable = true
    $0.spacing = 10
    $0.isSkeletonable = true
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  private let rothemImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.skeletonCornerRadius = 10
    $0.isSkeletonable = true
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.font = .regular18
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 5
    $0.isSkeletonable = true
  }
  
  init(noticeSeq: Int, viewModel: RothemNoticeDetailViewModelType = RothemNoticeDetailViewModel()) {
    self.noticeSeq = noticeSeq
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireRothemNoticeDetail(noticeSeq: noticeSeq)
    
    viewModel.noticeDetailModel
      .emit(with: self) { owner, result in
        let (title, content, thumbnailURL) = result
        
        owner.view.hideSkeleton()
        owner.titleLabel.text = title
        owner.contentLabel.text = content
        owner.rothemImageView.kf.setImage(with: thumbnailURL)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
            owner.navigationController?.popViewController(animated: true)
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "스터디 공지사항"
    setupBackButton()
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    _ = [titleLabel, rothemImageView, contentLabel].map { containerView.addArrangedSubview($0) }
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
    
    rothemImageView.snp.makeConstraints {
      $0.height.equalTo(200)
    }
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
