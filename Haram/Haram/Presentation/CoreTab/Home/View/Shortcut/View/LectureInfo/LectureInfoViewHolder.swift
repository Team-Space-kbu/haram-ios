//
//  LectureInfoViewHolder.swift
//  Haram
//
//  Created by 이건준 on 10/12/24.
//

import UIKit

import SnapKit
import Then

final class LectureInfoViewHolder {
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 20, left: 15, bottom: 15, right: 15)
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 15
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "강의실 정보"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let lectureListViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 15
  }
  
  lazy var lectureListView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: lectureListViewLayout).then {
    $0.register(LectureInfoCollectionViewCell.self)
    $0.isSkeletonable = true
  }
}

extension LectureInfoViewHolder: ViewHolderType {
  func place(in view: UIView) {
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [titleLabel, lectureListView].forEach { containerView.addArrangedSubview($0) }
  }
  
  func configureConstraints(for view: UIView) {
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
  }
}

