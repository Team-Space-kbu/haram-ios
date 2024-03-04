//
//  PopularAmenityCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/21.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct PopularAmenityCollectionViewCellModel {
  let amenityImageURL: URL?
  let amenityContent: String
  
  init(response: AmenityResponse) {
    amenityImageURL = URL(string: response.filePath)
    amenityContent = response.title
  }

}

final class PopularAmenityCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "PopularAmenityCollectionViewCell"
  
  private let amenityImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hex545E6A.cgColor
    $0.contentMode = .scaleAspectFit
  }
  
  private let amenityLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .black
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
    
    contentView.isSkeletonable = true
    contentView.backgroundColor = .clear
    [amenityLabel, amenityImageView].forEach { contentView.addSubview($0) }
    
    amenityLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(15)
    }
    
    amenityImageView.snp.makeConstraints {
      $0.bottom.equalTo(amenityLabel.snp.top)
      $0.centerX.top.equalToSuperview()
      $0.leading.greaterThanOrEqualToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
      $0.size.equalTo(40)
    }
  }
  
  func configureUI(with model: PopularAmenityCollectionViewCellModel) {
    amenityImageView.kf.setImage(with: model.amenityImageURL)
    amenityLabel.text = model.amenityContent
  }
}
