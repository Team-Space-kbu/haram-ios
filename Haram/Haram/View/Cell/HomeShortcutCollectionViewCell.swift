//
//  HomeShortcutCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

struct HomeShortcutCollectionViewCellModel {
  let imageName: String
}

final class HomeShortcutCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeShortcutCollectionViewCell"
  
  private let shortcutImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(shortcutImageView)
    shortcutImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomeShortcutCollectionViewCellModel) {
    shortcutImageView.image = UIImage(systemName: "heart.fill")
  }
}
