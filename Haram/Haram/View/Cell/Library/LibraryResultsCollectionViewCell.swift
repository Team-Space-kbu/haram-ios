//
//  LibraryResultsCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct LibraryResultsCollectionViewCellModel {
  let imageName: String
  let title: String
  let description: String
  let path: Int
  
  init(result: SearchBookResult) {
    imageName = result.imageName
    title = result.title
    description = result.description
    path = result.path
  }
}

final class LibraryResultsCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryResultsCollectionViewCell"
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.contentMode = .scaleAspectFit
    $0.isSkeletonable = true
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold16
    $0.numberOfLines = 2
    $0.isSkeletonable = true
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 1
    $0.isSkeletonable = true
  }
  
  private let bottomLineView = UIView().then {
    $0.backgroundColor = .hex9F9FA4
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
    bookImageView.image = nil
    mainLabel.text = nil
    subLabel.text = nil
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [bookImageView, mainLabel, subLabel, bottomLineView].forEach { contentView.addSubview($0) }
    bookImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.height.equalTo(112)
      $0.width.equalTo(80)
    }
    
    mainLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalTo(bookImageView.snp.trailing).offset(15)
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    subLabel.snp.makeConstraints {
      $0.leading.equalTo(mainLabel)
      $0.top.equalTo(mainLabel.snp.bottom).offset(2)
      $0.trailing.lessThanOrEqualToSuperview()
      $0.bottom.lessThanOrEqualTo(bookImageView)
    }
    
    bottomLineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryResultsCollectionViewCellModel) {
    let url = URL(string: model.imageName)
    bookImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "book"))
    mainLabel.text = model.title
    subLabel.text = model.description
  }
}
