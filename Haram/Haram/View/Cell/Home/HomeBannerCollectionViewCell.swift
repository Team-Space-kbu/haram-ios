//
//  HomeBannerCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct HomebannerCollectionViewCellModel {
  let imagePath: String
  
  init(subBanner: SubBanner) {
    imagePath = subBanner.filePath
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
  
  private func configureUI() {
    contentView.addSubview(bannerImageView)
    bannerImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: HomebannerCollectionViewCellModel) {
    let url = URL(string: model.imagePath)
    bannerImageView.kf.setImage(with: url)
  }
}
