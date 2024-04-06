//
//  HomeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import RxCocoa
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
  
  private var bannerModel: [HomebannerCollectionViewCellModel] = []
  
  private var newsModel: [HomeNewsCollectionViewCellModel] = []
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .always
    $0.showsVerticalScrollIndicator = false
    $0.alwaysBounceVertical = true
  }
  
  private let scrollContainerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 10, left: 15, bottom: 10, right: 15)
  }
  
  private let homeNoticeView = HomeNoticeView()
  
  private lazy var checkChapelDayView = CheckChapelDayView().then {
    $0.delegate = self
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
  }
  
  private let pageControl = UIPageControl().then {
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .systemGray2
    $0.currentPageIndicatorTintColor = UIColor.hex79BD9A
  }
  
  private lazy var shortcutCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 28.97
    }
  ).then {
    $0.backgroundColor = .white
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeShortcutCollectionViewCell.self, forCellWithReuseIdentifier: HomeShortcutCollectionViewCell.identifier)
    $0.register(HomeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier)
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
    $0.bounces = false
  }
  
  private let newsTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold22
    $0.text = "KBU 뉴스레터"
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
  }
  
  // MARK: - Initializations
  
  init(viewModel: HomeViewModelType = HomeViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.inquireSimpleChapelInfo()
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()

    _ = [scrollView, scrollContainerView, homeNoticeView, checkChapelDayView, newsCollectionView, newsTitleLabel, shortcutCollectionView, pageControl, bannerCollectionView].map { $0.isSkeletonable = true }
    print("두근 \(Environment.baseURLString)")
    let label = UILabel().then {
      $0.text = "성서알리미"
      $0.textColor = .black
      $0.font = .bold26
    }
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(scrollContainerView)
    [homeNoticeView, bannerCollectionView, pageControl, shortcutCollectionView, newsTitleLabel, newsCollectionView].forEach { scrollContainerView.addArrangedSubview($0) }
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
      $0.height.equalTo(35) //공지 뷰
    }
    
    bannerCollectionView.snp.makeConstraints {
      $0.height.equalTo(142)
    }
    
    pageControl.snp.makeConstraints {
      $0.height.equalTo(20)
    }
    
    shortcutCollectionView.snp.makeConstraints {
      $0.height.equalTo(30.94 + 28 + 54 + 54 + 28.97 + 22)
    }
    
    newsTitleLabel.snp.makeConstraints {
      $0.height.equalTo(27)
    }
    
    newsCollectionView.snp.makeConstraints {
      $0.height.equalTo(165 + 17 + 6)
    }
    
    scrollContainerView.setCustomSpacing(20, after: homeNoticeView)
    scrollContainerView.setCustomSpacing(22, after: pageControl)
    scrollContainerView.setCustomSpacing(13, after: newsTitleLabel)
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireHomeInfo()
    
    Driver.combineLatest(
      viewModel.newsModel,
      viewModel.bannerModel,
      viewModel.noticeModel,
      viewModel.isAvailableSimpleChapelModal
    )
    .drive(with: self) { owner, result in
      let (newsModel, bannerModel, noticeModel, modalModel) = result
      let (isAvailableSimpleChapelModal, checkChapelDayViewModel) = modalModel
      
      let isContain = owner.scrollContainerView.contains(owner.checkChapelDayView)
      
      
      if isAvailableSimpleChapelModal && !isContain {
        owner.checkChapelDayView.configureUI(with: checkChapelDayViewModel!)
        owner.scrollContainerView.insertArrangedSubview(owner.checkChapelDayView, at: 3)
      } else if !isAvailableSimpleChapelModal && isContain {
        owner.checkChapelDayView.removeFromSuperview()
      }
      
      owner.newsModel = newsModel
      owner.bannerModel = bannerModel
      owner.homeNoticeView.configureUI(with: noticeModel)
      
      if bannerModel.isEmpty {
        owner.bannerCollectionView.backgroundColor = .hex79BD9A
      }
      
      owner.view.hideSkeleton()
      
      owner.pageControl.numberOfPages = bannerModel.count
      owner.bannerCollectionView.reloadData()
      owner.newsCollectionView.reloadData()
    }
    .disposed(by: disposeBag)
    
    pageControl.rx.controlEvent(.valueChanged)
      .subscribe(with: self) { owner,  _ in
        owner.pageControlValueChanged(currentPage: owner.pageControl.currentPage)
      }
      .disposed(by: disposeBag)
    
    currentBannerPage
      .asDriver(onErrorDriveWith: .empty())
      .drive(pageControl.rx.currentPage)
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
        }
      }
      .disposed(by: disposeBag)
    
    homeNoticeView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.homeNoticeView.showAnimation {
          let vc = HomeNoticeViewController()
          vc.hidesBottomBarWhenPushed = true
          owner.navigationController?.pushViewController(vc, animated: true)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func pageControlValueChanged(currentPage: Int) {
    bannerCollectionView.isPagingEnabled = false
    bannerCollectionView.scrollToItem(at: .init(row: currentPage, section: 0), at: .left, animated: true)
    bannerCollectionView.isPagingEnabled = true
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if collectionView == shortcutCollectionView {
      return CGSize(width: (collectionView.frame.width - 30) / 4, height: 54)
    } else if collectionView == newsCollectionView {
      return CGSize(width: 118, height: 165 + 17 + 6)
    } else if collectionView == bannerCollectionView {
      return CGSize(width: collectionView.frame.width, height: 142)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if collectionView == shortcutCollectionView {
      return CGSize(width: collectionView.frame.width - 30, height: 30.94 + 28)
    }
    return .zero
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
    
    if collectionView == shortcutCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      let type = ShortcutType.allCases[indexPath.row]
      cell.configureUI(with: .init(title: type.title, imageResource: type.imageResource))
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
    if collectionView == shortcutCollectionView {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionHeaderView.identifier, for: indexPath) as? HomeCollectionHeaderView ?? HomeCollectionHeaderView()
      header.configureUI(with: HomeType.shortcut.title)
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if collectionView == shortcutCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      cell.showAnimation(scale: 0.9) { [weak self] in
        guard let self = self else { return }
        let type = ShortcutType.allCases[indexPath.row]
        let vc = type.viewController
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    } else if collectionView == newsCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? HomeNewsCollectionViewCell ?? HomeNewsCollectionViewCell()
      cell.showAnimation(scale: 0.9) { [weak self] in
        guard let self = self else { return }
        let model = self.newsModel[indexPath.row]
        let vc = PDFViewController(pdfURL: model.pdfURL)
        vc.title = model.title
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    } else {
      let cell = collectionView.cellForItem(at: indexPath) as? HomeBannerCollectionViewCell ?? HomeBannerCollectionViewCell()
      cell.showAnimation(scale: 0.9) { [weak self] in
        guard let self = self else { return }
        let model = self.bannerModel[indexPath.row]
        let vc = HomeBannerDetailViewController(department: model.department, bannerSeq: model.bannerSeq)
        vc.title = model.title
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
  
}

extension HomeViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == bannerCollectionView {
      return skeletonView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell
    } else if skeletonView == shortcutCollectionView {
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
    } else if skeletonView == shortcutCollectionView {
      return HomeShortcutCollectionViewCell.identifier
    }
    return HomeNewsCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    if skeletonView == shortcutCollectionView {
      return HomeCollectionHeaderView.identifier
    }
    return nil
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

extension HomeViewController: CheckChapelDayViewDelegate {
  func didTappedXButton() {
    if scrollContainerView.contains(checkChapelDayView) {
      checkChapelDayView.removeFromSuperview()
    }
  }
}

extension HomeViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.inquireHomeInfo()
  }
}
