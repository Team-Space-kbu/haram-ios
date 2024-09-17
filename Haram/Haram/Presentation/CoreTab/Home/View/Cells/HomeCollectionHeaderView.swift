//
//  HomeCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class HomeCollectionHeaderView: UICollectionReusableView, ReusableView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold22
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
    
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(13)
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}

