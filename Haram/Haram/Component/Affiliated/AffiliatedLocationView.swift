//
//  AffiliatedLocationView.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

struct AffiliatedLocationViewModel {
  let locationImageResource: ImageResource
  let locationContent: String
}

final class AffiliatedLocationView: UIView {
  
  private let locationImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private let locationLabel = UILabel().then {
    $0.textAlignment = .left
    $0.font = .regular12
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    _ = [locationImageView, locationLabel].map { addSubview($0) }
    locationImageView.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
      $0.width.equalTo(10)
    }
    
    locationLabel.snp.makeConstraints {
      $0.leading.equalTo(locationImageView.snp.trailing).offset(2)
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
  }
  
  func configureUI(with model: AffiliatedLocationViewModel) {
    locationImageView.image = UIImage(resource: model.locationImageResource)
    locationLabel.text = model.locationContent
  }
}
