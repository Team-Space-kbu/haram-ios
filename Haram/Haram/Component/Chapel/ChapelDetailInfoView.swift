//
//  ChapelInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit
  
import SnapKit
import SkeletonView
import Then

enum ChapelViewType: CaseIterable {
  case regulate
  case completionDays
  case remain
  case tardy
  
  var title: String {
    switch self {
    case .regulate:
      return "규정일수"
    case .completionDays:
      return "이수일수"
    case .remain:
      return "남은일수"
    case .tardy:
      return "지각"
    }
  }
}

struct ChapelDetailInfoViewModel {
  let title: String
  let day: String
}

final class ChapelDetailInfoView: UIView {

  private let titleLabel = UILabel().then {
    $0.text = "상세 정보"
    $0.font = .bold18
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  lazy var chapelDetailInfoView = AutoSizingCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return self.createChapelDetailInfoViewSection()
    }
  ).then {
    $0.register(ChapelDetailCell.self)
    $0.backgroundColor = .white
    $0.isScrollEnabled = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, chapelDetailInfoView].forEach {
      $0.isSkeletonable = true
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    chapelDetailInfoView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(143.21 + 15)
    }
  }
  
  private func createChapelDetailInfoViewSection() -> NSCollectionLayoutSection {
    let firstItemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1/3),
      heightDimension: .fractionalHeight(1.0)
    )
    let firstItem = NSCollectionLayoutItem(layoutSize: firstItemSize)
    
    let firstGroupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(64)
    )
    let firstGroup = NSCollectionLayoutGroup.horizontal(layoutSize: firstGroupSize, subitems: [firstItem])
    firstGroup.interItemSpacing = .fixed(20)
    
    // 두 번째 줄: 셀 2개
    let secondItemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1/2),
      heightDimension: .fractionalHeight(1.0)
    )
    let secondItem = NSCollectionLayoutItem(layoutSize: secondItemSize)
    
    let secondGroupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(64)
    )
    let secondGroup = NSCollectionLayoutGroup.horizontal(layoutSize: secondGroupSize, subitems: [secondItem])
    secondGroup.interItemSpacing = .fixed(19)
    
    // 두 그룹을 세로로 배치
    let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(143.21 + 15))
    let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: nestedGroupSize, subitems: [firstGroup, secondGroup])
    nestedGroup.interItemSpacing = .fixed(15)
    
    let section = NSCollectionLayoutSection(group: nestedGroup)
    section.orthogonalScrollingBehavior = .none
    section.contentInsets = .init(top: 15, leading: 15, bottom: .zero, trailing: 15)
    return section
  }
}
