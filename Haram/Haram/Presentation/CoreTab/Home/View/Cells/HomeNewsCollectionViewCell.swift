//
//  HomeNewsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
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

final class HomeNewsCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let outerView = UIView().then {
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.28
    $0.layer.shadowRadius = 6
    $0.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    $0.layer.backgroundColor = UIColor.clear.cgColor
  }
  
  private let newsImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
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
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [outerView, titleLabel].forEach { contentView.addSubview($0) }
    outerView.addSubview(newsImageView)
    outerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(165)
    }
    
    newsImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
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
