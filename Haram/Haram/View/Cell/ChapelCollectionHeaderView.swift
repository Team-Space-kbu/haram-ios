//
//  ChapelCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

import SnapKit
import Then

final class ChapelCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "ChapelCollectionHeaderView"
  
  private let sectionTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold
    $0.sizeToFit()
    $0.text = "채플정보"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(sectionTitleLabel)
    sectionTitleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
    }
  }
}
