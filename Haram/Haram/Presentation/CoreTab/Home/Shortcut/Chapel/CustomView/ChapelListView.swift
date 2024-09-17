//
//  ChapelListView.swift
//  Haram
//
//  Created by 이건준 on 9/22/24.
//

import UIKit

import SnapKit
import Then

final class ChapelListView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold22
    $0.text = "채플정보"
  }
  
  lazy var chapelCollectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
    $0.sectionInset = .init(top: 14, left: 15, bottom: 15, right: 15)
  }).then {
    $0.register(ChapelCollectionViewCell.self)
    $0.backgroundColor = .white
//    $0.isSkeletonable = true
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
    isSkeletonable = true
    [titleLabel, chapelCollectionView].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    chapelCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
}

final class AutoSizingCollectionView: UICollectionView {
  
  override var intrinsicContentSize: CGSize {
    return contentSize
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if bounds.size != intrinsicContentSize {
      invalidateIntrinsicContentSize()
    }
  }
}
