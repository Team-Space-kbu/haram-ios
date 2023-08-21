//
//  PopularAmenityCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/21.
//

import UIKit

import SnapKit
import Then

final class PopularAmenityCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "PopularAmenityCollectionViewCell"
  
  private let amenityImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hex545E6A.cgColor
    $0.contentMode = .scaleAspectFill
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
    contentView.backgroundColor = .clear
    [amenityImageView, amenityLabel].forEach { contentView.addSubview($0) }
  }
}
