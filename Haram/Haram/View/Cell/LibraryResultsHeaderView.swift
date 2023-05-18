//
//  LibraryResultsHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class LibraryResultsHeaderView: UICollectionReusableView {
  
  static let identifier = "LibraryResultsHeaderView"
  
  private let titleLabel = UILabel().then {
    $0.font = .bold
    $0.font = .systemFont(ofSize: 20)
    $0.textColor = .black
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
