//
//  BibleViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

enum BibleType: CaseIterable {
  case todayBibleWord
  case notice
  case todayPray
  
  var title: String {
    switch self {
    case .todayBibleWord:
      return "오늘의성경말씀"
    case .notice:
      return "공지사항"
    case .todayPray:
      return "오늘의기도"
    }
  }
}

final class BibleViewController: BaseViewController {
  
  private lazy var bibleCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return type(of: self).createCollectionViewSection(type: BibleType.allCases[sec])
  }).then {
    $0.register(BibleCollectionViewCell.self, forCellWithReuseIdentifier: BibleCollectionViewCell.identifier)
    $0.register(TodayBibleWordCollectionViewCell.self, forCellWithReuseIdentifier: TodayBibleWordCollectionViewCell.identifier)
    $0.register(BibleNoticeCollectionViewCell.self, forCellWithReuseIdentifier: BibleNoticeCollectionViewCell.identifier)
    $0.register(BibleCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BibleCollectionHeaderView.identifier)
    $0.dataSource = self
    $0.delegate = self
//    $0.contentInset = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private lazy var bibleSearchView = BibleSearchView().then {
    $0.delegate = self
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "성경"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(bibleCollectionView)
    view.addSubview(bibleSearchView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    bibleCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    bibleSearchView.snp.makeConstraints {
      $0.height.equalTo(186 - 30)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  static func createCollectionViewSection(type: BibleType) -> NSCollectionLayoutSection? {
    switch type {
    case .todayBibleWord:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(22)
      ))
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(22)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24 + 13)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 15, bottom: 28, trailing: 15)
      section.boundarySupplementaryItems = [header]
      return section
    case .notice:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(22)
      ))
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(161)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24 + 12)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 15, bottom: 28, trailing: 15)
      section.boundarySupplementaryItems = [header]
      return section
    case .todayPray:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      ))
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(85)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24 + 14)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 15, bottom: 156, trailing: 15)
      section.interGroupSpacing = 20
      return section
    }
  }
}

extension BibleViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return BibleType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if BibleType.allCases[section] == .todayPray {
      return 5
    }
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch BibleType.allCases[indexPath.section] {
    case .todayBibleWord:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayBibleWordCollectionViewCell.identifier, for: indexPath) as? TodayBibleWordCollectionViewCell ?? TodayBibleWordCollectionViewCell()
      return cell
    case .notice:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BibleNoticeCollectionViewCell.identifier, for: indexPath) as? BibleNoticeCollectionViewCell ?? BibleNoticeCollectionViewCell()
      return cell
    case .todayPray:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BibleCollectionViewCell.identifier, for: indexPath) as? BibleCollectionViewCell ?? BibleCollectionViewCell()
      cell.configureUI(with: .init(prayTitle: "기도제목", prayContent: "제발성공적으로 하람이 잘 개발되었으면 좋겠습니다.제발성공적으로 하람이 잘 개발되었으면 좋겠습니다.제발성공적으로 하람이 잘 개발되었으면 좋겠습니다.제발성공적으로 하람이 잘 개발되었으면 좋겠습니다.제발성공적으로 하람이 잘 개발되었으면 좋겠습니다."))
      return cell
    }
  }
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//    switch BibleType.allCases[section] {
//    case .todayBibleWord:
//      return CGSize(width: collectionView.frame.width, height: 24 + 13)
//    case .notice:
//      return CGSize(width: collectionView.frame.width, height: 24 + 12)
//    case .todayPray:
//      return CGSize(width: collectionView.frame.width, height: 24 + 14)
//    }
//  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BibleCollectionHeaderView.identifier, for: indexPath) as? BibleCollectionHeaderView ?? BibleCollectionHeaderView()
    header.configureUI(with: BibleType.allCases[indexPath.section].title)
    return header
  }
}

extension BibleViewController: BibleSearchViewDelgate {
  func didTappedSearchButton() {
    let vc = BibleSearchResultViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}
