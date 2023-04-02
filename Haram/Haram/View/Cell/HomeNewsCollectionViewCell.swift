//
//  HomeNewsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

struct HomeNewsCollectionViewCellModel {
  let thumbnailName: String
}

final class HomeNewsCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeNewsCollectionViewCell"
  
  private let newsImageView = UIImageView().then {
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
    contentView.addSubview(newsImageView)
    newsImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomeNewsCollectionViewCellModel) {
    newsImageView.image = UIImage(systemName: "heart.fill")
  }
}
