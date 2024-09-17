//
//  SelectedTimeCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

final class SelectedTimeCollectionHeaderView: UICollectionReusableView, ReusableView {
  
  private let titleLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex1A1E27
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
      $0.top.leading.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
