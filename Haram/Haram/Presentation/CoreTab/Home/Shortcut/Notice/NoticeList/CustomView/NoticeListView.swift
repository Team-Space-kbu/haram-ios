//
//  NoticeListView.swift
//  Haram
//
//  Created by 이건준 on 9/30/24.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class NoticeListView: UIView {
  
  private var noticeModel: [NoticeCollectionViewCellModel] = []
  
  lazy var noticeCollectionView = AutoSizingCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self)
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
    $0.dataSource = self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    isSkeletonable = true
    addSubview(noticeCollectionView)
    noticeCollectionView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureUI(with model: [NoticeCollectionViewCellModel]) {
    self.noticeModel = model
    noticeCollectionView.reloadData()
  }
}

extension NoticeListView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return noticeModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(NoticeCollectionViewCell.self, for: indexPath) ?? NoticeCollectionViewCell()
    cell.configureUI(with: noticeModel[indexPath.row])
    return cell
  }
}

extension NoticeListView: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    NoticeCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(NoticeCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
}
