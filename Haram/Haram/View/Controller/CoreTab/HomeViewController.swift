//
//  HomeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

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
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [collectionView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
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
          heightDimension: .absolute(50)
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
          widthDimension: .fractionalWidth(1/4),
          heightDimension: .absolute(200)),
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
      return 8
    case .news:
      return 8
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let type = HomeType.allCases[indexPath.section]
    switch type {
    case .shortcut:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeShortcutCollectionViewCell.identifier, for: indexPath) as? HomeShortcutCollectionViewCell ?? HomeShortcutCollectionViewCell()
      cell.configureUI(with: .init(imageName: ""))
      return cell
    case .news:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeNewsCollectionViewCell.identifier, for: indexPath) as? HomeNewsCollectionViewCell ?? HomeNewsCollectionViewCell()
      cell.configureUI(with: .init(thumbnailName: ""))
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
