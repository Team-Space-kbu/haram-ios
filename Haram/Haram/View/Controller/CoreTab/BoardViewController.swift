//
//  BoardViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

enum SchoolBoardType: CaseIterable {
  case notice
  case club
  case department
  
  var title: String {
    switch self {
    case .notice:
      return "총학공지사항"
    case .club:
      return "동아리게시판"
    case .department:
      return "학과게시판"
    }
  }
  
  var imageName: String {
    switch self {
    case .notice:
      return "noticeBlack"
    case .club:
      return "clubBlue"
    case .department:
      return "departmentRed"
    }
  }
}

enum NormalBoardType: CaseIterable {
  case free
  case secret
  case think
  case infor
  case date
  case study
  
  var title: String {
    switch self {
    case .free:
      return "자유게시판"
    case .secret:
      return "비밀게시판"
    case .think:
      return "고민게시판"
    case .infor:
      return "정보게시판"
    case .date:
      return "연애게시판"
    case .study:
      return "스터디게시판"
    }
  }
  
  var imageName: String {
    switch self {
    case .free:
      return "freeGreen"
    case .secret:
      return "secretGreen"
    case .think:
      return "thinkYellow"
    case .infor:
      return "inforRed"
    case .date:
      return "dateBlack"
    case .study:
      return "studyPurple"
    }
  }
}

final class BoardViewController: BaseViewController {
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 64, left: 15, bottom: .zero, right: 15)
  }
  
  private let boardLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "게시판"
    $0.font = .bold
    $0.font = .systemFont(ofSize: 26)
  }
  
  private let schoolLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "학교게시판"
    $0.font = .bold
    $0.font = .systemFont(ofSize: 22)
  }
  
  private let normalBoardLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "일반게시판"
    $0.font = .bold
    $0.font = .systemFont(ofSize: 22)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(contentStackView)
    [boardLabel, schoolLabel].forEach { contentStackView.addArrangedSubview($0)
    }
    for type in SchoolBoardType.allCases {
      let listView = BoardListView()
      listView.configureUI(with: BoardListViewModel(imageName: type.imageName, title: type.title))
      listView.snp.makeConstraints {
        $0.height.equalTo(46)
      }
      contentStackView.addArrangedSubview(listView)
    }
    
    contentStackView.addArrangedSubview(normalBoardLabel)
    
    for type in NormalBoardType.allCases {
      let listView = BoardListView()
      listView.configureUI(with: BoardListViewModel(imageName: type.imageName, title: type.title))
      contentStackView.addArrangedSubview(listView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    contentStackView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    contentStackView.setCustomSpacing(22, after: boardLabel)
    contentStackView.setCustomSpacing(13, after: schoolLabel)
    contentStackView.setCustomSpacing(13, after: normalBoardLabel)
  }
}
