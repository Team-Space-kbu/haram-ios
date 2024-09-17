//
//  BoardListViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/07/30.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import SkeletonView
import Then

final class BoardListViewController: BaseViewController {
  
  private let viewModel: BoardListViewModel
  
  private var boardListModel: [BoardListCollectionViewCellModel] = []
  
  private let boardListCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .clear
    $0.register(BoardListCollectionViewCell.self)
    $0.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = true
  }
  
  private lazy var editBoardButton = UIButton().then {
    $0.layer.cornerRadius = 25
    $0.backgroundColor = .hex79BD9A
    $0.setImage(UIImage(resource: .editButton), for: .normal)
    $0.layer.shadowColor = UIColor(hex: 0x000000).cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowRadius = 5
    $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 25
  }
  
  private lazy var emptyView = EmptyView(text: "게시글이 없습니다.")
  
  init(viewModel: BoardListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set CollectionView delegate & dataSource
    boardListCollectionView.delegate = self
    boardListCollectionView.dataSource = self
    
    /// Set Navigationbar
    setupBackButton()
    
    setupSkeletonView()
    emptyView.isHidden = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    _ = [boardListCollectionView, emptyView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    emptyView.snp.makeConstraints { 
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    let didScrollToBottom = boardListCollectionView.rx.contentOffset
      .map { [weak self] offset -> Bool in
        guard let self = self else { return false }
        let offSetY = offset.y
        let contentHeight = self.boardListCollectionView.contentSize.height
        let frameHeight = self.boardListCollectionView.frame.size.height
        return offSetY > (contentHeight - frameHeight)
      }
      .filter { $0 }
      .map { _ in Void() }
    
    let input = BoardListViewModel.Input(
      viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in Void() },
      didTapBoardListCell: boardListCollectionView.rx.itemSelected.asObservable(),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didTapEditButton: editBoardButton.rx.tap.asObservable(), 
      didScrollToBottom: didScrollToBottom
    )
    let output = viewModel.transform(input: input)
    
    output.currentBoardList
      .skip(1)
      .subscribe(with: self) { owner, model in
        owner.emptyView.isHidden = !model.isEmpty
        owner.boardListModel = model
        
        owner.view.hideSkeleton()
        
        owner.boardListCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    output.writeableBoard
      .subscribe(with: self) { owner, isEnabled in
        if isEnabled {
          owner.view.addSubview(owner.editBoardButton)
          owner.editBoardButton.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.bottomMargin.equalToSuperview().inset(54)
            $0.trailing.equalToSuperview().inset(15)
          }
        }
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    boardListModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(BoardListCollectionViewCell.self, for: indexPath) ?? BoardListCollectionViewCell()
    cell.configureUI(with: boardListModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if collectionView == boardListCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? BoardListCollectionViewCell ?? BoardListCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if collectionView == boardListCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? BoardListCollectionViewCell ?? BoardListCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
    }
  }
}

extension BoardListViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    BoardListCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(BoardListCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
}

extension BoardListViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshBoardModel), name: .refreshBoardModel, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshBoardModel() {
//    viewModel.refreshBoardList(categorySeq: categorySeq)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
//    viewModel.refreshBoardList(categorySeq: categorySeq)
  }
}

extension BoardListViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
