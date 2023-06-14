//
//  HomeNewsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct HomeNewsCollectionViewCellModel {
  let title: String
  let thumbnailName: String
  
  init(kbuNews: KbuNews) {
    title = kbuNews.title
    thumbnailName = kbuNews.filePath
  }
}

final class HomeNewsCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeNewsCollectionViewCell"
  
  private let newsImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .bold
    $0.font = .systemFont(ofSize: 14)
    $0.sizeToFit()
    $0.numberOfLines = 1
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [newsImageView, titleLabel].forEach { contentView.addSubview($0) }
    newsImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(165)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(newsImageView.snp.bottom).offset(6)
      $0.leading.equalToSuperview()
      $0.trailing.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: HomeNewsCollectionViewCellModel) {
    let url = URL(string: model.thumbnailName)
    newsImageView.kf.setImage(with: url)
    titleLabel.text = model.title
  }
}
