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
  let thumbnailURL: URL?
  let pdfURL: URL?
  
  init(kokkoksNews: KokkoksNews) {
    title = kokkoksNews.title
    thumbnailURL = URL(string: kokkoksNews.img)
    pdfURL = URL(string: kokkoksNews.file)
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
    $0.font = .bold14
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    newsImageView.image = nil
    titleLabel.text = nil
  }
  
  private func configureUI() {
    contentView.addShadow(shadowRadius: 6, shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 3))
    
    [newsImageView, titleLabel].forEach { contentView.addSubview($0) }
    newsImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(165)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(newsImageView.snp.bottom).offset(6)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: HomeNewsCollectionViewCellModel) {
    newsImageView.kf.setImage(with: model.thumbnailURL)
    titleLabel.text = model.title
  }
}
