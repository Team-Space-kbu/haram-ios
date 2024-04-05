//
//  LibraryRelatedBookCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct LibraryRelatedBookCollectionViewCellModel {
  let path: Int
  let bookImageURL: URL?
  
  init(relatedBook: RelatedBook) {
    path = relatedBook.path
    bookImageURL = URL(string: relatedBook.image)
  }
}

final class LibraryRelatedBookCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryRelatedBookCollectionViewCell"
  
  private let bookImageView = UIImageView().then {
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
  
  private func configureUI() {
    isSkeletonable = true
    
    skeletonCornerRadius = 10
    contentView.addShadow(shadowRadius: 6, shadowOpacity: 0.28, shadowOffset: CGSize(width: 0, height: 3))
    
    contentView.addSubview(bookImageView)
    bookImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryRelatedBookCollectionViewCellModel) {
    hideSkeleton()
    bookImageView.kf.setImage(with: model.bookImageURL, placeholder: UIImage(systemName: "book"))
  }
}
