//
//  NoticeCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/27.
//

import UIKit

import SnapKit
import Then

final class NoticeCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "NoticeCollectionHeaderView"
  
  private let categoryLabel = UILabel().then {
    $0.font = .medium16
    $0.textColor = .hex02162E
    $0.text = "카테고리"
  }
  
  private let categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 15
      $0.minimumInteritemSpacing = 15
    }
  ).then {
    $0.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
    $0.backgroundColor = .clear
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    /// Set CollectionView delegate & dataSource
    categoryCollectionView.delegate = self
    categoryCollectionView.dataSource = self
    
    /// Set Layout
    [categoryLabel, categoryCollectionView].forEach { addSubview($0) }
    
    categoryLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    categoryCollectionView.snp.makeConstraints {
      $0.top.equalTo(categoryLabel.snp.bottom).offset(17)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(41 + 71 + 41)
    }
  }
  
  func configureUI(with model: String) {
    
  }
}

extension NoticeCollectionHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return CategorySectionType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell ?? CategoryCollectionViewCell()
    cell.configureUI(with: CategorySectionType.allCases[indexPath.row].title)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let label = UILabel().then {
      $0.font = .medium18
      $0.text = CategorySectionType.allCases[indexPath.row].title
      $0.sizeToFit()
    }
    return CGSize(width: label.frame.size.width + 30, height: 41)
  }
}
