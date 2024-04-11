//
//  HomeBannerDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class BannerDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: HomeBannerDetailViewModelType
  private let bannerSeq: Int
  private let department: Department
  private var bannerModel: [HomebannerCollectionViewCellModel] = []
  
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
  
  private lazy var bannerCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = .zero
    }
  ).then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeBannerCollectionViewCell.self, forCellWithReuseIdentifier: HomeBannerCollectionViewCell.identifier)
    $0.alwaysBounceHorizontal = true
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = true
    $0.skeletonCornerRadius = 10
    $0.isSkeletonable = true
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.font = .regular18
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 5
  }
  
  init(department: Department, bannerSeq: Int, viewModel: HomeBannerDetailViewModelType = HomeBannerDetailViewModel()) {
    self.viewModel = viewModel
    self.bannerSeq = bannerSeq
    self.department = department
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireBannerInfo(bannerSeq: bannerSeq, department: department)
    
    viewModel.bannerInfo
      .emit(with: self) { owner, result in
        let (title, content, imageModel) = result
        owner.bannerModel = imageModel
        owner.view.hideSkeleton()
        
        owner.bannerCollectionView.reloadData()
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
    _ = [titleLabel, bannerCollectionView, contentLabel].map { containerView.addArrangedSubview($0) }
    
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
    
    bannerCollectionView.snp.makeConstraints {
      $0.height.equalTo(200)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupSkeletonView()
    setupBackButton()
//    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension BannerDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension BannerDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: collectionView.frame.width, height: 200)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    bannerModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell ?? HomeBannerCollectionViewCell()
    cell.configureUI(with: bannerModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let cell = collectionView.cellForItem(at: indexPath) as? HomeBannerCollectionViewCell ?? HomeBannerCollectionViewCell()
    cell.showAnimation(scale: 0.9) { [weak self] in
      guard let self = self else { return }
      if let zoomImageURL = self.bannerModel[indexPath.row].imageURL {
        let modal = ZoomImageViewController(zoomImageURL: zoomImageURL)
        modal.modalPresentationStyle = .fullScreen
        self.present(modal, animated: true)
      } else {
        AlertManager.showAlert(title: "이미지 확대 알림", message: "해당 이미지는 확대할 수 없습니다", viewController: self, confirmHandler: nil)
      }
    }
  }
}

extension BannerDetailViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    HomeBannerCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
}
