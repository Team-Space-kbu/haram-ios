//
//  HomeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import Alamofire
import RxSwift
import SnapKit
import Then

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
  
  private let currentBannerPage = PublishSubject<Int>()
  
  private var bannerModel: [HomebannerCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadSections([0])
    }
  }
  
  private var newsModel: [HomeNewsCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadSections([2])
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let scrollContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let homeNoticeView = HomeNoticeView()
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return self.createSection(type: HomeType.allCases[sec])
    }
  ).then {
    $0.backgroundColor = .systemBackground
    $0.delegate = self
    $0.dataSource = self
    $0.register(HomeShortcutCollectionViewCell.self, forCellWithReuseIdentifier: HomeShortcutCollectionViewCell.identifier)
    $0.register(HomeNewsCollectionViewCell.self, forCellWithReuseIdentifier: HomeNewsCollectionViewCell.identifier)
    $0.register(HomeBannerCollectionViewCell.self, forCellWithReuseIdentifier: HomeBannerCollectionViewCell.identifier)
    $0.register(HomeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier)
    $0.register(PagingSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingSectionFooterView.identifier)
    
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
  }
  
  override func setupStyles() {
    super.setupStyles()
    let label = UILabel().then {
      $0.text = "하람"
      $0.font = .bold
      $0.font = .systemFont(ofSize: 26)
    }
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(scrollContainerView)
    [homeNoticeView, collectionView].forEach { scrollContainerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
    
    scrollContainerView.snp.makeConstraints {
      $0.width.directionalVerticalEdges.equalToSuperview()
    }
    
    homeNoticeView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(35) //공지 뷰
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(homeNoticeView.snp.bottom).offset(20)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(15)
      $0.height.equalTo(UIScreen.main.bounds.height - (20 + 70 + 20 + 35))
    }
  }
  
  override func bind() {
    super.bind()
    HomeService.shared.inquireHomeInfo()
      .subscribe(with: self) { owner, response in
        owner.newsModel = response.kokkoks.kbuNews.map { HomeNewsCollectionViewCellModel(kbuNews: $0) }
        
        owner.bannerModel = response.banner.banners.map { HomebannerCollectionViewCellModel(subBanner: $0) }
      }
      .disposed(by: disposeBag)
  }
  
  private func createSection(type: HomeType) -> NSCollectionLayoutSection? {
    switch type {
    case .banner:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1))
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(142)),
        repeatingSubitem: item,
        count: 1
      )
      
      let footerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(20)
      )
      
      let pagingFooterElement = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: footerSize,
        elementKind: UICollectionView.elementKindSectionFooter,
        alignment: .bottom
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPaging
      section.boundarySupplementaryItems = [pagingFooterElement]
      section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
        let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
          self?.currentBannerPage.onNext(bannerIndex)
     }
      
      return section
    case .shortcut:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1))
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/4),
          heightDimension: .fractionalWidth(1/4)),
        repeatingSubitem: item,
        count: 4
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(18 + 26 + 32.94)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.orthogonalScrollingBehavior = .none
      return section
      
    case .news:
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1))
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(119),
          heightDimension: .absolute(206)),
        repeatingSubitem: item,
        count: 1
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(50)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.orthogonalScrollingBehavior = .groupPaging
      section.interGroupSpacing = 22
      return section
    }
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return HomeType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let type = HomeType.allCases[section]
    switch type {
    case .banner:
      return bannerModel.count
    case .shortcut:
      return ShortcutType.allCases.count
    case .news:
      return newsModel.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let type = HomeType.allCases[indexPath.section]
    switch type {
    case .banner:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.identifier, for: indexPath) as? HomeBannerCollectionViewCell ?? HomeBannerCollectionViewCell()
      cell.configureUI(with: bannerModel[indexPath.row])
      return cell
    case .shortcut:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      let type = ShortcutType.allCases[indexPath.row]
      cell.configureUI(with: .init(title: type.title, imageName: type.imageName))
      return cell
    case .news:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeNewsCollectionViewCell.identifier, for: indexPath) as? HomeNewsCollectionViewCell ?? HomeNewsCollectionViewCell()
      cell.configureUI(with: newsModel[indexPath.row])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter && indexPath.section == 0 {
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PagingSectionFooterView.identifier, for: indexPath) as? PagingSectionFooterView ?? PagingSectionFooterView()
      footer.setPageControl(subBanners: bannerModel, currentPage: currentBannerPage)
      return footer
    }
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionHeaderView.identifier, for: indexPath) as? HomeCollectionHeaderView ?? HomeCollectionHeaderView()
    header.configureUI(with: HomeType.allCases[indexPath.section].title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let homeSection = HomeType.allCases[indexPath.section]
    switch homeSection {
    case .banner:
      print("배너클릭")
    case .shortcut:
      let type = ShortcutType.allCases[indexPath.row]
      switch type {
      case .mileage:
        print("잉")
      case .chapel:
        if !UserManager.shared.hasIntranetToken {
          let vc = IntranetLoginViewController()
          vc.navigationItem.largeTitleDisplayMode = .never
          navigationController?.pushViewController(vc, animated: true)
        } else {
          let vc = ChapelViewController()
          vc.navigationItem.largeTitleDisplayMode = .never
          vc.hidesBottomBarWhenPushed = true
          vc.navigationItem.backButtonTitle = nil
          navigationController?.pushViewController(vc, animated: true)
        }
      case .notice:
        let vc = NoticeViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.backButtonTitle = nil
        navigationController?.pushViewController(vc, animated: true)
      case .searchBook:
        let vc = LibraryViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.backButtonTitle = nil
        navigationController?.pushViewController(vc, animated: true)
      case .searchBible:
        print("잉")
      case .affiliate:
        print("잉")
      case .eventSchedule:
        print("잉")
      case .readingRoom:
        print("잉")
      }
    case .news:
      print("잉")
    }
  }
  
}
