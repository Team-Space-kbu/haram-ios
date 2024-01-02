//
//  HomeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

// MARK: - HomeType

enum HomeType: CaseIterable {
  case banner
  case shortcut
  case news
  
  var title: String {
    switch self {
    case .banner:
      return "배너"
    case .shortcut:
      return "바로가기"
    case .news:
      return "KBU 뉴스레터"
    }
  }
}

final class HomeViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: HomeViewModelType
  
  private let currentBannerPage = PublishSubject<Int>()
  
  // MARK: - UI Models
  
  private var bannerModel: [HomebannerCollectionViewCellModel] = [] {
    didSet {
      pageControl.numberOfPages = bannerModel.count
      bannerCollectionView.reloadData()
    }
  }
  
  private var newsModel: [HomeNewsCollectionViewCellModel] = [] {
    didSet {
      newsCollectionView.reloadData()
    }
  }
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .always
    $0.showsVerticalScrollIndicator = false
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
  }
  
  private let scrollContainerView = UIView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let homeNoticeView = HomeNoticeView().then {
    $0.isSkeletonable = true
  }
  
  private lazy var bannerCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
    }
  ).then {
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeBannerCollectionViewCell.self, forCellWithReuseIdentifier: HomeBannerCollectionViewCell.identifier)
    $0.alwaysBounceHorizontal = true
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = true
    $0.isSkeletonable = true
  }
  
  private let pageControl = UIPageControl().then {
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .systemGray2
    $0.currentPageIndicatorTintColor = UIColor.hex79BD9A
    $0.isSkeletonable = true
  }
  
  private lazy var homeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 28.97
    }
  ).then {
    $0.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 22, right: .zero)
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeShortcutCollectionViewCell.self, forCellWithReuseIdentifier: HomeShortcutCollectionViewCell.identifier)
    $0.register(HomeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier)
    
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
    $0.isSkeletonable = true
  }
  
  private let newsTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold22
    $0.text = "KBU 뉴스레터"
    $0.isSkeletonable = true
  }
  
  private lazy var newsCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 23
    }
  ).then {
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeNewsCollectionViewCell.self, forCellWithReuseIdentifier: HomeNewsCollectionViewCell.identifier)
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: HomeViewModelType = HomeViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    let label = UILabel().then {
      $0.text = "하람"
      $0.textColor = .black
      $0.font = .bold26
    }
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    
    /// Configure Skeleton UI
    view.isSkeletonable = true
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
    let graient = SkeletonGradient(baseColor: .skeletonDefault)
    
    view.showAnimatedGradientSkeleton(
      usingGradient: graient,
      animation: skeletonAnimation,
      transition: .none
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(scrollContainerView)
    [homeNoticeView, bannerCollectionView, pageControl, homeCollectionView, newsTitleLabel, newsCollectionView].forEach { scrollContainerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    scrollContainerView.snp.makeConstraints {
      $0.width.directionalVerticalEdges.equalToSuperview()
    }
    
    homeNoticeView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(35) //공지 뷰
    }
    
    bannerCollectionView.snp.makeConstraints {
      $0.top.equalTo(homeNoticeView.snp.bottom).offset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(142)
    }
    
    pageControl.snp.makeConstraints {
      $0.top.equalTo(bannerCollectionView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(20)
    }
    
    homeCollectionView.snp.makeConstraints {
      $0.top.equalTo(pageControl.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(194)
    }
    
    newsTitleLabel.snp.makeConstraints {
      $0.top.equalTo(homeCollectionView.snp.bottom).offset(22)
      $0.leading.equalToSuperview().inset(15)
      $0.height.equalTo(27)
    }
    
    newsCollectionView.snp.makeConstraints {
      $0.top.equalTo(newsTitleLabel.snp.bottom).offset(13)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(165 + 17 + 6)
      $0.bottom.lessThanOrEqualToSuperview().inset(10)
    }
    
    
  }
  
  override func bind() {
    super.bind()
    
    viewModel.newsModel
      .drive(rx.newsModel)
      .disposed(by: disposeBag)
    
    viewModel.bannerModel
      .drive(rx.bannerModel)
      .disposed(by: disposeBag)
    
    viewModel.noticeModel
      .emit(with: self) { owner, model in
        owner.homeNoticeView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, _ in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
    
    pageControl.rx.controlEvent(.valueChanged)
      .subscribe(with: self) { owner,  _ in
        owner.bannerCollectionView.scrollToItem(at: .init(row: owner.pageControl.currentPage, section: 0), at: .left, animated: true)
      }
      .disposed(by: disposeBag)
    
    currentBannerPage
      .asDriver(onErrorDriveWith: .empty())
      .drive(pageControl.rx.currentPage)
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if collectionView == homeCollectionView {
      return CGSize(width: (collectionView.frame.width - 30) / 4, height: 54)
    } else if collectionView == newsCollectionView {
      return CGSize(width: 118, height: 165 + 17 + 6)
    }
    return CGSize(width: collectionView.frame.width - 30, height: 142)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if collectionView == homeCollectionView {
      return CGSize(width: collectionView.frame.width - 30, height: 30.94 + 28)
    }
    return .zero
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == bannerCollectionView {
      return bannerModel.count
    } else if collectionView == newsCollectionView {
      return newsModel.count
    }
    return ShortcutType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView == homeCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      let type = ShortcutType.allCases[indexPath.row]
      cell.configureUI(with: .init(title: type.title, imageName: type.imageName))
      return cell
    } else if collectionView == newsCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeNewsCollectionViewCell.identifier, for: indexPath) as? HomeNewsCollectionViewCell ?? HomeNewsCollectionViewCell()
      cell.configureUI(with: newsModel[indexPath.row])
      return cell
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell ?? HomeBannerCollectionViewCell()
    cell.configureUI(with: bannerModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if collectionView == homeCollectionView {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionHeaderView.identifier, for: indexPath) as? HomeCollectionHeaderView ?? HomeCollectionHeaderView()
      header.configureUI(with: HomeType.shortcut.title)
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if collectionView == homeCollectionView {
      let type = ShortcutType.allCases[indexPath.row]
      let vc = type.viewController
      vc.navigationItem.largeTitleDisplayMode = .never
      vc.hidesBottomBarWhenPushed = true
      navigationController?.interactivePopGestureRecognizer?.delegate = self
      navigationController?.pushViewController(vc, animated: true)
    } else if collectionView == newsCollectionView {
      let vc = PDFViewController(pdfURL: newsModel[indexPath.row].pdfURL)
      vc.title = newsModel[indexPath.row].title
      vc.navigationItem.largeTitleDisplayMode = .never
      vc.hidesBottomBarWhenPushed = true
      navigationController?.interactivePopGestureRecognizer?.delegate = self
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension HomeViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == bannerCollectionView {
      return skeletonView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell
    } else if skeletonView == homeCollectionView {
      return skeletonView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell
    }
    return skeletonView.dequeueReusableCell(withReuseIdentifier: HomeNewsCollectionViewCell.identifier, for: indexPath) as? HomeNewsCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    if skeletonView == bannerCollectionView {
      return HomeBannerCollectionViewCell.identifier
    } else if skeletonView == homeCollectionView {
      return HomeShortcutCollectionViewCell.identifier
    }
    return HomeNewsCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    if skeletonView == homeCollectionView {
      return HomeCollectionHeaderView.identifier
    }
    return nil
  }
}

extension HomeViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
}

extension HomeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView == bannerCollectionView else { return }
    let contentOffset = scrollView.contentOffset
    let bannerIndex = Int(max(0, round(contentOffset.x / scrollView.bounds.width)))
    
    self.currentBannerPage.onNext(bannerIndex)
  }
}