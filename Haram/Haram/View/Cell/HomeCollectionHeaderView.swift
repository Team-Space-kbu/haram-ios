//
//  HomeCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

final class HomeCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "HomeCollectionHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
