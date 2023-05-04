//
//  MoreViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

enum MoreType: CaseIterable {
  case graduationCondition
  case inquireEmptyClass
  case todayPray
  case civilComplaint
  
  var title: String {
    switch self {
    case .graduationCondition:
      return "졸업조건확인"
    case .inquireEmptyClass:
      return "빈강의실조회"
    case .todayPray:
      return "오늘의기도"
    case .civilComplaint:
      return "민원건의"
    }
  }
  
  var imageName: String {
    switch self {
    case .graduationCondition:
      return "scholarGreen"
    case .inquireEmptyClass:
      return "monitorRed"
    case .todayPray:
      return "starBlue"
    case .civilComplaint:
      return "warningYellow"
    }
  }
}

enum SettingType: CaseIterable {
  case haramQA
  case version
  case provision
  case license
  case logout
  
  var title: String {
    switch self {
    case .haramQA:
      return "하람 Q&A"
    case .version:
      return "버전관리"
    case .provision:
      return "하람서비스약관"
    case .license:
      return "오픈소스라이센스"
    case .logout:
      return "로그아웃"
    }
  }
}

final class MoreViewController: BaseViewController {
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 19
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private let moreLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold
    $0.font = .systemFont(ofSize: 26)
    $0.text = "더보기"
  }
  
  private let settingLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold
    $0.font = .systemFont(ofSize: 22)
    $0.text = "설정"
  }
  
  private let profileInfoView = ProfileInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.backgroundColor = .hexF8F8F8
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(contentStackView)
    [moreLabel, profileInfoView].forEach { contentStackView.addArrangedSubview($0) }
    
    for type in MoreType.allCases {
      let listView = MoreListView(type: .image)
      listView.configureUI(with: .init(imageName: type.imageName, title: type.title))
      contentStackView.addArrangedSubview(listView)
    }
    
    [lineView, settingLabel].forEach { contentStackView.addArrangedSubview($0) }
    
    for type in SettingType.allCases {
      let listView = MoreListView(type: .noImage)
      listView.configureUI(with: .init(imageName: nil, title: type.title))
      contentStackView.addArrangedSubview(listView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    contentStackView.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    profileInfoView.snp.makeConstraints {
      $0.height.equalTo(131)
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
    }
    
    contentStackView.setCustomSpacing(67, after: moreLabel)
    
    
  }
}
