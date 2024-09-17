//
//  NoticeCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/27.
//

import UIKit

import SnapKit
import SkeletonView
import Then

protocol NoticeCollectionHeaderViewDelegate: AnyObject {
  func didTappedCategory(noticeType: NoticeType)
}

final class NoticeCollectionHeaderView: UICollectionReusableView, ReusableView {

  weak var delegate: NoticeCollectionHeaderViewDelegate?
  private var model: [MainNoticeType] = [] {
    didSet {
      categoryCollectionView.reloadData()
    }
  }
  
  private let categoryLabel = UILabel().then {
    $0.font = .medium16
    $0.textColor = .hex02162E
    $0.text = "카테고리"
    $0.isSkeletonable = true
  }
  
  private let categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 15
      $0.minimumInteritemSpacing = 15
    }
  ).then {
    $0.register(CategoryCollectionViewCell.self)
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    
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
  
  func configureUI(with model: [MainNoticeType]) {
    self.model = model
  }
}

extension NoticeCollectionHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(CategoryCollectionViewCell.self, for: indexPath) ?? CategoryCollectionViewCell()
    cell.configureUI(with: model[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let model = model[safe: indexPath.row] {
      let label = UILabel().then {
        $0.font = .medium18
        $0.text = model.tag
        $0.sizeToFit()
      }
      return CGSize(width: label.frame.size.width + 30, height: 41)
    } else {
      let label = UILabel().then {
        $0.font = .medium18
        $0.text = NoticeType.noticeCategoryList[indexPath.row].title
        $0.sizeToFit()
      }
      return CGSize(width: label.frame.size.width + 30, height: 41)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.didTappedCategory(noticeType: model[indexPath.row].key)
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if collectionView == categoryCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell ?? CategoryCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if collectionView == categoryCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell ?? CategoryCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
    }
  }
}

extension NoticeCollectionHeaderView: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    CategoryCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(CategoryCollectionViewCell.self, for: indexPath) ?? CategoryCollectionViewCell()    
    cell.configureUI(with: .init(key: .library, tag: "도서관"))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    NoticeType.noticeCategoryList.count
  }
}

extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
