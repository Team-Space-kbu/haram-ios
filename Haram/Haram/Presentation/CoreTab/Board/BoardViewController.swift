//
//  BoardViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import SkeletonView
import SnapKit
import Then

final class BoardViewController: BaseViewController {
  
  private let viewModel: BoardViewModel
  
  private var boardModel: [BoardTableViewCellModel] = []
  private var boardHeaderTitle: String?
  
  private lazy var boardTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(BoardTableViewCell.self)
    $0.register(BoardTableHeaderView.self)
    $0.delegate = self
    $0.dataSource = self
    $0.sectionHeaderHeight = 28 + 11
    $0.backgroundColor = .white
    $0.separatorStyle = .none
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  init(viewModel: BoardViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    let input = BoardViewModel.Input(
      viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in Void() },
      didTapBoardCell: boardTableView.rx.itemSelected.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    
    Observable.combineLatest(
      output.boardModel,
      output.boardHeaderTitle
    )
    .subscribe(with: self) { owner, result in
      let (model, headerTitle) = result
      owner.boardModel = model
      owner.boardHeaderTitle = headerTitle
      
        owner.view.hideSkeleton()
      
      owner.boardTableView.reloadData()
    }
    .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: owner.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
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

extension BoardViewController {
  private func bindNotificationCenter(input: BoardViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension BoardViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    boardModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(BoardTableViewCell.self, for: indexPath) ?? BoardTableViewCell()
    cell.configureUI(with: boardModel[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BoardTableHeaderView.reuseIdentifier) as? BoardTableHeaderView ?? BoardTableHeaderView()
    headerView.configureUI(with: "학교 게시판")
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46 + 10
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
    skeletonView.dequeueReusableCell(BoardTableViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    BoardTableViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
    BoardTableHeaderView.reuseIdentifier
  }
}
