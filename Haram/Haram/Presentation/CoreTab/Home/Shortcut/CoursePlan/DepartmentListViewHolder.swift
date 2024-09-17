//
//  DepartmentListViewHolder.swift
//  Haram
//
//  Created by 이건준 on 10/9/24.
//

import UIKit

import SnapKit
import Then

final class DepartmentListViewHolder {
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
    $0.text = "학과선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let majorListViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 15
  }
  
  lazy var majorListView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: majorListViewLayout).then {
    $0.register(ClassCollectionViewCell.self)
    $0.isSkeletonable = true
  }
}

extension DepartmentListViewHolder: ViewHolderType {
  func place(in view: UIView) {
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [titleLabel, majorListView].forEach { containerView.addArrangedSubview($0) }
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
