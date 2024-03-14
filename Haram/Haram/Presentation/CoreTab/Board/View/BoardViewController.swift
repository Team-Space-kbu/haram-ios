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
  
  private let viewModel: BoardViewModelType
  
  private var boardModel: [BoardTableViewCellModel] = [] {
    didSet {
      boardTableView.reloadData()
    }
  }
  
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
    $0.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 69 - 21, right: 15)
  }
  
  private lazy var boardTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(BoardTableViewCell.self, forCellReuseIdentifier: BoardTableViewCell.identifier)
    $0.register(BoardTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BoardTableHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
//    $0.sectionFooterHeight = 21
    $0.sectionHeaderHeight = 28 + 11
    $0.backgroundColor = .white
    $0.separatorStyle = .none
//    $0.isScrollEnabled = false
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
  }
  
  init(viewModel: BoardViewModelType = BoardViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireBoardCategory()
    viewModel.boardModel
      .drive(rx.boardModel)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    let label = UILabel().then {
      $0.text = "게시판"
      $0.textColor = .black
      $0.font = .bold26
    }
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
//    self.tabBarController?.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(boardTableView)
//    view.addSubview(scrollView)
//    scrollView.addSubview(containerView)
//    [boardTableView].forEach { containerView.addArrangedSubview($0) }
    
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
//    scrollView.snp.makeConstraints {
//      $0.directionalEdges.equalToSuperview()
//    }
//    
//    containerView.snp.makeConstraints {
//      $0.top.width.equalToSuperview()
//      $0.bottom.lessThanOrEqualToSuperview()
//    }
    
    boardTableView.snp.makeConstraints {
      $0.topMargin.equalToSuperview().inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
//      $0.directionalEdges.equalToSuperview()
//      $0.height.equalTo(28 + 509 + 46 + 21)
    }
  }
}

extension BoardViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    boardModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: BoardTableViewCell.identifier, for: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
    cell.configureUI(with: boardModel[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BoardTableHeaderView.identifier) as? BoardTableHeaderView ?? BoardTableHeaderView()
    headerView.configureUI(with: "학교 게시판")
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46 + 10
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
//    tableView.deselectRow(at: indexPath, animated: true)
    
    let boardModel = boardModel[indexPath.row]
    let vc = BoardListViewController(
      categorySeq: boardModel.categorySeq,
      writeableBoard: boardModel.writeableBoard
    )
    vc.title = boardModel.title
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    if tableView == boardTableView {
      let cell = tableView.cellForRow(at: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
      cell.setHighlighted(isHighlighted: true)
      
      
//      let pressedDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//      UIView.transition(with: cell.contentView, duration: 0.1) {
////        cell.alpha = 0.5
//        cell.setBackgroundColor(isHighlighted: true)
//        cell.contentView.transform = pressedDownTransform
//      }
    }
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    if tableView == boardTableView {
      let cell = tableView.cellForRow(at: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
      cell.setHighlighted(isHighlighted: false)
//      let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
//      UIView.transition(with: cell.contentView, duration: 0.1) {
////        cell.contentView.backgroundColor = .clear
////        cell.alpha = 1
//        cell.setBackgroundColor(isHighlighted: false)
//        cell.contentView.transform = .identity
//      }
    }
  }
  
}
