//
//  LibraryResultsCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import SnapKit
import Then

final class LibraryResultsCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "LibraryResultsCollectionHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular
    $0.font = .systemFont(ofSize: 18)
    $0.text = "검색내역"
    $0.sizeToFit()
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
