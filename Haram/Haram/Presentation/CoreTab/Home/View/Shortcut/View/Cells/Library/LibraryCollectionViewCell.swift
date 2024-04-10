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

struct LibraryCollectionViewCellModel {
  let path: Int
  let imageNameURL: URL?
  
  init(bookInfo: BookInfo) {
    path = bookInfo.path
    imageNameURL = URL(string: bookInfo.image)
  }
  
  init(relatedBook: RelatedBook) {
    path = relatedBook.path
    imageNameURL = URL(string: relatedBook.image)
  }
}

final class LibraryCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryCollectionViewCell"
  
  private let thumbnailImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
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
    
    skeletonCornerRadius = 10
    contentView.addShadow(shadowRadius: 6, shadowOpacity: 0.28, shadowOffset: CGSize(width: 0, height: 3))
    contentView.addSubview(thumbnailImageView)
    thumbnailImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryCollectionViewCellModel) {
    hideSkeleton()
    thumbnailImageView.kf.setImage(with: model.imageNameURL, placeholder: UIImage(systemName: "book"))
  }
}
