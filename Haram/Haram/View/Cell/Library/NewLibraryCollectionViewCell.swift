//
//  LibraryResultsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct NewLibraryCollectionViewCellModel {
  let path: Int
  let imageName: String
  
  init(bookInfo: BookInfo) {
    path = bookInfo.path
    imageName = bookInfo.image
  }
}

final class NewLibraryCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "NewLibraryCollectionViewCell"
  
  private let thumbnailImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.isSkeletonable = true
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
    thumbnailImageView.image = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    contentView.addSubview(thumbnailImageView)
    thumbnailImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: NewLibraryCollectionViewCellModel) {
    let url = URL(string: model.imageName)
    thumbnailImageView.kf.setImage(with: url)
    contentView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
  }
}
