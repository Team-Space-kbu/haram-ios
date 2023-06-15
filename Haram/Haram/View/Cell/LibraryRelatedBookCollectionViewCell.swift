//
//  LibraryRelatedBookCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct LibraryRelatedBookCollectionViewCellModel {
  let bookImageURL: String
}

final class LibraryRelatedBookCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryRelatedBookCollectionViewCell"
  
  private let bookImageView = UIImageView().then {
    $0.backgroundColor = .systemGray
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
    layer.masksToBounds = true
    layer.cornerRadius = 10
    backgroundColor = .systemGray
    contentView.addSubview(bookImageView)
    bookImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryRelatedBookCollectionViewCellModel) {
    let url = URL(string: model.bookImageURL)
    bookImageView.kf.setImage(with: url)
  }
}
