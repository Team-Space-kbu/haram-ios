//
//  BibleCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

final class BibleCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "BibleCollectionViewCell"
  
  private let bibleNameLabel = UILabel().then {
    $0.text = "창세기"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(bibleNameLabel)
    bibleNameLabel.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
  }
}
