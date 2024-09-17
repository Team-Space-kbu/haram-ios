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

final class PopularAmenityCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let amenityImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.clear.cgColor
    $0.contentMode = .scaleAspectFit
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  private let amenityLabel = UILabel().then {
    $0.font = .regular12
    $0.textColor = .black
    $0.textAlignment = .center
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
    amenityImageView.layer.borderColor = nil
    amenityImageView.image = nil
    amenityLabel.text = nil
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
      $0.top.centerX.equalToSuperview()
      $0.size.equalTo(40)
    }
  }
  
  func configureUI(with model: PopularAmenityCollectionViewCellModel) {
    amenityImageView.layer.borderColor = UIColor.hex545E6A.cgColor
    amenityImageView.kf.setImage(with: model.amenityImageURL)
    amenityLabel.text = model.amenityContent
  }
}
