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
  let title: String
  let thumbnailName: String
}

final class HomeNewsCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeNewsCollectionViewCell"
  
  private let newsImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.backgroundColor = .lightGray
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .systemFont(ofSize: 14)
    $0.font = .bold
    $0.text = "코코스 2022년 4월호"
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
    [newsImageView, titleLabel].forEach { contentView.addSubview($0) }
    newsImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(165)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(newsImageView.snp.bottom).offset(6)
      $0.leading.bottom.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: HomeNewsCollectionViewCellModel) {
//    newsImageView.image = UIImage(systemName: "heart.fill")
  }
}
