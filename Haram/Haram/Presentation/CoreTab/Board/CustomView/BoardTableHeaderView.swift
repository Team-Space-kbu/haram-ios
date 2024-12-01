//
//  BoardTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/31.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class BoardTableHeaderView: UITableViewHeaderFooterView, ReusableView {
  
  private let titleLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .hex1A1E27
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
    $0.skeletonTextLineHeight = .fixed(28)
    $0.text = "학교 게시판"
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(11)
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
