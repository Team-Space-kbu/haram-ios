//
//  HomeBannerCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct HomebannerCollectionViewCellModel {
  let bannerSeq: Int
  let imageURL: URL?
  let title: String
  let department: Department
  
  init(subBanner: SubBanner) {
    department = subBanner.department
    title = subBanner.title
    bannerSeq = subBanner.seq
    imageURL = URL(string: subBanner.filePath)
  }
}

final class HomeBannerCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "HomeBannerCollectionViewCell"
  
  private let bannerImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
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
    bannerImageView.image = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    skeletonCornerRadius = 10
    contentView.isSkeletonable = true
    contentView.addSubview(bannerImageView)
    bannerImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomebannerCollectionViewCellModel) {
    bannerImageView.kf.setImage(with: model.imageURL)
  }
}
