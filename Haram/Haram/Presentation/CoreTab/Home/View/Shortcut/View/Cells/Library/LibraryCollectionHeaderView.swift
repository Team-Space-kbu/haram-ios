//
//  LibraryResultsHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class LibraryCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "LibraryCollectionHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .black
    $0.textAlignment = .left
    $0.skeletonTextNumberOfLines = 1
    $0.isSkeletonable = true
    $0.text = "인기도서"
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
      $0.top.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(17)
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
