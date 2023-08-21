//
//  BibleBottomSheetViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

final class BibleBottomSheetViewController: BottomSheetViewController {
  
  private lazy var bibleCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(BibleCollectionViewCell.self, forCellWithReuseIdentifier: BibleCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(bibleCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    bibleCollectionView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.height.equalTo(UIScreen.main.bounds.height - 200)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
  }
}

extension BibleBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BibleCollectionViewCell.identifier, for: indexPath) as? BibleCollectionViewCell ?? BibleCollectionViewCell()
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 50)
  }
}
