//
//  CampusBuildingListViewHolder.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class CampusBuildingListViewHolder {
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 20, left: .zero, bottom: 15, right: .zero)
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 18
    $0.isSkeletonable = true
  }
  
  let alertInfoListView = AlertInfoListView()
  let classListView = ClassListView()
}

extension CampusBuildingListViewHolder: ViewHolderType {
  func place(in view: UIView) {
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [alertInfoListView, classListView]
    containerView.addArrangedDividerSubViews(subViews, thickness: 10)
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
