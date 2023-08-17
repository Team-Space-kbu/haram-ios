//
//  LibraryResultsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct LibraryCollectionViewCellModel {
  let imageName: String
  
  init(newBook: NewBook) {
    imageName = newBook.image
  }
  
  init(bestBook: BestBook) {
    imageName = bestBook.image
  }
}

final class LibraryCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryCollectionViewCell"
  
  private let thumbnailImageView = UIImageView().then {
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
    contentView.addSubview(thumbnailImageView)
    thumbnailImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryCollectionViewCellModel) {
    guard let url = URL(string: model.imageName) else { return }
    thumbnailImageView.kf.setImage(with: url)
  }
}
