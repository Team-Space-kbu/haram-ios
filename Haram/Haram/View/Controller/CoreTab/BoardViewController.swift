//
//  BoardViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import SnapKit
import Then

final class BoardViewController: BaseViewController {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 20
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: 69 - 21, right: 15)
  }
  
  private lazy var boardTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(BoardTableViewCell.self, forCellReuseIdentifier: BoardTableViewCell.identifier)
    $0.register(BoardTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BoardTableHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.sectionFooterHeight = 21
    $0.sectionHeaderHeight = 28 + 11
    $0.backgroundColor = .white
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
  }
  
  private let boardLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "게시판"
    $0.font = .bold26
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
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
      $0.height.equalTo(28 + 509 + 46 + 21)
    }
  }
}

extension BoardViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 3
    }
    return 6
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    let cell = tableView.dequeueReusableCell(withIdentifier: BoardTableViewCell.identifier, for: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
    if section == 0 {
      let model: BoardType = [.STUDENT_COUNCIL, .CLUB, .DEPARTMENT][indexPath.row]
      cell.configureUI(with: .init(imageName: model.imageName, title: model.title))
    } else if section == 1{
      let model: BoardType = [.FREE, .SECRET, .WORRIES, .INFORMATION, .DATING, .STUDY][indexPath.row]
      cell.configureUI(with: .init(imageName: model.imageName, title: model.title))
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BoardTableHeaderView.identifier) as? BoardTableHeaderView ?? BoardTableHeaderView()
    if section == 0 {
      headerView.configureUI(with: "학교게시판")
    } else if section == 1 {
      headerView.configureUI(with: "일반게시판")
    }
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46 + 10
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = BoardListViewController(
      type: indexPath.section == 0 ? BoardType.allCases[0...2][indexPath.row] : BoardType.allCases[3...8][indexPath.row + 3]
    )
    vc.title = "게시판"
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension BoardViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
}
