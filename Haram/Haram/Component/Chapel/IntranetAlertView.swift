//
//  IntranetAlertView.swift
//  Haram
//
//  Created by 이건준 on 3/3/24.
//

import UIKit

import SnapKit
import SkeletonView
import Then

enum IntranetAlertViewType {
  case mileage
  case chapel
  
  var title: String {
    switch self {
    case .mileage:
      return "마일리지반영"
    case .chapel:
      return "채플정보안내"
    }
  }
  
  var description: String {
    switch self {
    case .mileage:
      return "마일리지정보가 반영되는데 일정시간이 소요됩니다"
    case .chapel:
      return "인트라넷정보와 차이가 발생할 수 있습니다"
    }
  }
}

final class IntranetAlertView: UIView {
  
  private let type: IntranetAlertViewType
  
  private let rocketImageView = UIImageView(image: UIImage(resource: .rocketBlue)).then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 22.5
    $0.layer.masksToBounds = true
  }
  
  private let alertMainLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex545E6A
  }
  
  private let alertDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
  }
  
  init(type: IntranetAlertViewType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    
    _ = [rocketImageView, alertMainLabel, alertDescriptionLabel].map { addSubview($0) }
    rocketImageView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.width.equalTo(45)
    }
    
    alertMainLabel.snp.makeConstraints {
      $0.top.equalTo(rocketImageView)
      $0.leading.equalTo(rocketImageView.snp.trailing).offset(10)
    }
    
    alertDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(alertMainLabel.snp.bottom)
      $0.leading.equalTo(alertMainLabel)
      $0.bottom.equalTo(rocketImageView)
    }
    
    alertMainLabel.text = type.title
    alertDescriptionLabel.text = type.description
  }
}
