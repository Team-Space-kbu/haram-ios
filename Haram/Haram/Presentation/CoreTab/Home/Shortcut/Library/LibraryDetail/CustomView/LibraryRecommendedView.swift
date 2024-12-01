//
//  LibraryRecommendedView.swift
//  Haram
//
//  Created by 이건준 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class LibraryRecommendedView: UIView {
  
  private let relatedBookLabel = UILabel().then {
    $0.text = "추천도서"
    $0.font = .bold18
    $0.textColor = .black
  }
  
  lazy var relatedBookCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 20
      $0.sectionInset = .init(top: .zero, left: 15, bottom: 15, right: 15)
    }
  ).then {
    $0.backgroundColor = .clear
    $0.register(LibraryCollectionViewCell.self)
    $0.showsHorizontalScrollIndicator = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    
    [relatedBookLabel, relatedBookCollectionView].forEach { addSubview($0) }
    
    relatedBookLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(15)
      $0.height.equalTo(23)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    relatedBookCollectionView.snp.makeConstraints {
      $0.top.equalTo(relatedBookLabel.snp.bottom).offset(12)
      $0.height.equalTo(165 + 15 + 3 + 3)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
}
