//
//  EmptyCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SnapKit
import Then

final class EmptyCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let alertLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex9F9FA4
    $0.textAlignment = .center
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(alertLabel)
    alertLabel.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    alertLabel.text = model
  }
  
}
