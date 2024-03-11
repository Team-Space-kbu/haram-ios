//
//  BoardListViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/07/30.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class BoardListViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: BoardListViewModelType
  private let categorySeq: Int
  private let writeableBoard: Bool
  
  private var boardListModel: [BoardListCollectionViewCellModel] = [] {
    didSet {
      boardListCollectionView.reloadData()
    }
  }
  
  private let boardListCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .clear
    $0.register(BoardListCollectionViewCell.self, forCellWithReuseIdentifier: BoardListCollectionViewCell.identifier)
    $0.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: .zero, right: 15)
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
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
  
  init(categorySeq: Int, writeableBoard: Bool, viewModel: BoardListViewModelType = BoardListViewModel()) {
    self.viewModel = viewModel
    self.categorySeq = categorySeq
    self.writeableBoard = writeableBoard
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
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
    
    registerNotifications()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    _ = [boardListCollectionView, emptyView].map { view.addSubview($0) }
    
    if writeableBoard {
      view.addSubview(editBoardButton)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    emptyView.snp.makeConstraints { 
      $0.directionalEdges.equalToSuperview()
    }
    
    if writeableBoard {
      editBoardButton.snp.makeConstraints {
        $0.size.equalTo(50)
        $0.bottomMargin.equalToSuperview().inset(54)
        $0.trailing.equalToSuperview().inset(15)
      }
    }
    
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireBoardList(categorySeq: categorySeq)
    
    viewModel.boardListModel
      .skip(1)
      .drive(with: self) { owner, model in
        owner.emptyView.isHidden = !model.isEmpty
        owner.boardListModel = model
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, isLoading in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
    
    editBoardButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        let vc = EditBoardViewController(categorySeq: owner.categorySeq)
        vc.title = "게시글 작성"
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
//    viewModel.errorMessage
//      .emit(with: self) { owner, error in
//        guard error == .noExistBoard else { return }
//        owner.emptyView.isHidden = false
//      }
//      .disposed(by: disposeBag)
  }
  
  @objc
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    boardListModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardListCollectionViewCell.identifier, for: indexPath) as? BoardListCollectionViewCell ?? BoardListCollectionViewCell()
    cell.configureUI(with: boardListModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = BoardDetailViewController(categorySeq: categorySeq, boardSeq: boardListModel[indexPath.row].boardSeq)
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.title = title
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension BoardListViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    BoardListCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(withReuseIdentifier: BoardListCollectionViewCell.identifier, for: indexPath) as? BoardListCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
}

extension BoardListViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshBoardList), name: .refreshBoardList, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self, name: .refreshBoardList, object: nil)
  }
  
  @objc
  private func refreshBoardList() {
    viewModel.inquireBoardList(categorySeq: categorySeq)
  }
}
