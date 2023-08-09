//
//  BoardTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/31.
//

import UIKit

import SnapKit
import Then

final class BoardTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "BoardTableHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
