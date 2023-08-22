//
//  BibleCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

final class BibleCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "BibleCollectionHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .hex1A1E27
    $0.textAlignment = .left
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
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
