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
  let imageURL: URL?
  let title: String
  let description: String
  let path: Int
  
  init(result: SearchBookResult) {
    imageURL = URL(string: result.imageName)
    title = result.title
    description = result.description
    path = result.path
  }
}

final class LibraryResultsCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "LibraryResultsCollectionViewCell"
  
  private let outerView = UIView().then {
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.28
    $0.layer.shadowRadius = 6
    $0.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    $0.layer.backgroundColor = UIColor.clear.cgColor
  }
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.contentMode = .scaleAspectFill
    $0.skeletonCornerRadius = 10
  }
  
  private let mainLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold16
    $0.numberOfLines = 2
  }
  
  private let subLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 1
  }
  
  private let bottomLineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
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
    
    [outerView, mainLabel, subLabel, bottomLineView, bookImageView].forEach {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    outerView.addSubview(bookImageView)
    
    outerView.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.height.equalTo(112)
      $0.width.equalTo(80)
    }
    
    bookImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
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
    
    hideSkeleton()
    
    bookImageView.kf.setImage(with: model.imageURL, placeholder: UIImage(systemName: "book"))
    mainLabel.text = model.title
    subLabel.text = model.description
  }
}
