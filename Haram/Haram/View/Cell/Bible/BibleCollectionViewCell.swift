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
    $0.textColor = .black
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
    bibleNameLabel.text = nil
  }
  
  private func configureUI() {
    contentView.addSubview(bibleNameLabel)
    bibleNameLabel.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    bibleNameLabel.text = model
  }
}
