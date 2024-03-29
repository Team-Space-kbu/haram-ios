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
    $0.font = .bold22
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
  }
  
  private func configureUI() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(12)
    }
  }
  
  func configureUI(with model: String) {
    titleLabel.text = model
  }
}
