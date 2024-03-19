//
//  BoardViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxCocoa
import SkeletonView
import SnapKit
import Then

final class BoardViewController: BaseViewController {
  
  private let viewModel: BoardViewModelType
  
  private var boardModel: [BoardTableViewCellModel] = []
  private var boardHeaderTitle: String?
  
  private lazy var boardTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(BoardTableViewCell.self, forCellReuseIdentifier: BoardTableViewCell.identifier)
    $0.register(BoardTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BoardTableHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.sectionHeaderHeight = 28 + 11
    $0.backgroundColor = .white
    $0.separatorStyle = .none
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
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
    
    Driver.combineLatest(
      viewModel.boardModel,
      viewModel.boardHeaderTitle
    )
    .drive(with: self) { owner, result in
      let (model, headerTitle) = result
      owner.boardModel = model
      owner.boardHeaderTitle = headerTitle
      
        owner.view.hideSkeleton()
      
      owner.boardTableView.reloadData()
    }
    .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터 연결 후 다시 시도해주세요.", viewController: owner) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
          }
        }
      }
      .disposed(by: disposeBag)
      
  }
  
  override func setupStyles() {
    super.setupStyles()
    let label = UILabel().then {
      $0.text = "게시판"
      $0.textColor = .black
      $0.font = .bold26
    }
    setupSkeletonView()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(boardTableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    boardTableView.snp.makeConstraints {
      $0.topMargin.equalToSuperview().inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
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
//    guard let boardHeaderTitle = boardHeaderTitle else { return nil }
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BoardTableHeaderView.identifier) as? BoardTableHeaderView ?? BoardTableHeaderView()
    headerView.configureUI(with: "학교 게시판")
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46 + 10
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
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
    }
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    if tableView == boardTableView {
      let cell = tableView.cellForRow(at: indexPath) as? BoardTableViewCell ?? BoardTableViewCell()
      cell.setHighlighted(isHighlighted: false)
    }
  }
}

extension BoardViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    skeletonView.dequeueReusableCell(withIdentifier: BoardTableViewCell.identifier, for: indexPath) as? BoardTableViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    BoardTableViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
    BoardTableHeaderView.identifier
  }
}
