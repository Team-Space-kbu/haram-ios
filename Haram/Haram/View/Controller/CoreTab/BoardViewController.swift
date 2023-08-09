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
  
  static let headerTitle = "학교게시판"
  
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
  
  static let headerTitle = "일반게시판"
  
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
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 20
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  private lazy var boardTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(BoardTableViewCell.self, forCellReuseIdentifier: BoardTableViewCell.identifier)
    $0.register(BoardTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BoardTableHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.sectionFooterHeight = 21
    $0.sectionHeaderHeight = 28 + 11
    $0.backgroundColor = .systemBackground
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
  }
  
  private let boardLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "게시판"
    $0.font = .bold26
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [boardLabel, boardTableView].forEach { containerView.addArrangedSubview($0) }
    
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }

    boardTableView.snp.makeConstraints {
      $0.height.equalTo(28 + 509 + 46)
    }
  }
}

extension BoardViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return SchoolBoardType.allCases.count
    }
    return NormalBoardType.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    let cell = tableView.dequeueReusableCell(withIdentifier: BoardTableViewCell.identifier, for: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
    if section == 0 {
      cell.configureUI(with: .init(imageName: SchoolBoardType.allCases[indexPath.row].imageName, title: SchoolBoardType.allCases[indexPath.row].title))
    } else if section == 1{
      cell.configureUI(with: .init(imageName: NormalBoardType.allCases[indexPath.row].imageName, title: NormalBoardType.allCases[indexPath.row].title))
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BoardTableHeaderView.identifier) as? BoardTableHeaderView ?? BoardTableHeaderView()
    if section == 0 {
      headerView.configureUI(with: SchoolBoardType.headerTitle)
    } else if section == 1 {
      headerView.configureUI(with: NormalBoardType.headerTitle)
    }
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46 + 10
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = BoardListViewController()
    vc.title = "게시판"
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
}
