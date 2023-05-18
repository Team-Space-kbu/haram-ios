//
//  HomeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import SnapKit
import Then

enum HomeType: CaseIterable {
  case shortcut
  case news
  
  var title: String {
    switch self {
    case .shortcut:
      return "바로가기"
    case .news:
      return "KBU 뉴스레터"
    }
  }
}

final class HomeViewController: BaseViewController {
  
  private let disposeBag = DisposeBag()
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let scrollContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let haramSectionView = HaramSectionView()
  
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
    $0.register(HomeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeCollectionHeaderView.identifier)
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(scrollContainerView)
    [haramSectionView, collectionView].forEach { scrollContainerView.addSubview($0) }
    
    AuthService.shared.registerMember(request: .init(userID: "kilee124", email: "kilee125@naver.com", password: "1234", nickname: "건준이에용"))
      .subscribe(onNext: { response in
        print("응답 \(response)")
      })
      .disposed(by: disposeBag)
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
    
    haramSectionView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(20 + 70 + 20 + 140 + 20 + 35) // bottomInset + 팝업높이 + offset + 광고 뷰 높이 + offset + 공지 뷰
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(haramSectionView.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(15)
      $0.height.equalTo(UIScreen.main.bounds.height - (20 + 70 + 20 + 140 + 20 + 35))
    }
  }
  
  private func createSection(type: HomeType) -> NSCollectionLayoutSection? {
    switch type {
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
          widthDimension: .absolute(118),
          heightDimension: .absolute(165 + 6 + 18)),
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
    case .shortcut:
      return ShortcutType.allCases.count
    case .news:
      return 8
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let type = HomeType.allCases[indexPath.section]
    switch type {
    case .shortcut:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      let type = ShortcutType.allCases[indexPath.row]
      cell.configureUI(with: .init(title: type.title, imageName: type.imageName))
      return cell
    case .news:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeNewsCollectionViewCell.identifier, for: indexPath) as? HomeNewsCollectionViewCell ?? HomeNewsCollectionViewCell()
      cell.configureUI(with: .init(title: "", thumbnailName: ""))
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let type = HomeType.allCases[indexPath.section]
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionHeaderView.identifier, for: indexPath) as? HomeCollectionHeaderView ?? HomeCollectionHeaderView()
    header.configureUI(with: HomeType.allCases[indexPath.section].title)
    return header
  }
  
  
}
