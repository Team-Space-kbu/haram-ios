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

enum ChapelAlertType {
  case info
  case inquiry
  
  var title: String {
    switch self {
    case .info:
      return "채플 정보 반영"
    case .inquiry:
      return "채플 관련 문의"
    }
  }
  
  var description: String {
    switch self {
    case .info:
      return "인트라넷 채플정보와 차이가 발생할 수 있습니다."
    case .inquiry:
      return "교목실(02-950-5439)로 문의하면 됩니다."
    }
  }
  
  var mainTitle: String {
    switch self {
    case .info:
      return "반영"
    case .inquiry:
      return "문의"
    }
  }
  
  var color: UIColor {
    switch self {
    case .info:
      return .hexA8DBA8
    case .inquiry:
      return .hexFFB6B6
    }
  }
}

final class IntranetAlertView: UIView {
  
  private let type: ChapelAlertType
  
  private lazy var mainView = UILabel().then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
    $0.textColor = .white
    $0.font = .bold12
    $0.text = type.mainTitle
    $0.backgroundColor = type.color
    $0.textAlignment = .center
  }
  
  private lazy var alertTitleLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .hex545E6A
    $0.isSkeletonable = true
    $0.text = type.title
  }
  
  private lazy var alertDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.text = type.description
  }
  
  init(type: ChapelAlertType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    
    _ = [mainView, alertTitleLabel, alertDescriptionLabel].map { addSubview($0) }
    mainView.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
      $0.size.equalTo(40)
    }
    
    alertTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mainView.snp.top).offset(4)
      $0.leading.equalTo(mainView.snp.trailing).offset(9)
    }
    
    alertDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(alertTitleLabel.snp.bottom)
      $0.leading.equalTo(alertTitleLabel)
      $0.trailing.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
}

extension IntranetAlertView {
  func configureUI(
    mainTitle: String,
    mainColor: UIColor,
    alertTitle: String,
    alertDescription: String
  ) {
    mainView.text = mainTitle
    mainView.backgroundColor = mainColor
    alertTitleLabel.text = alertTitle
    alertDescriptionLabel.text = alertDescription
  }
}
