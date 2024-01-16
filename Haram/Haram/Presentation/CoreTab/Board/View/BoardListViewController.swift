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
  private let type: BoardType
  
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
    $0.contentInset = UIEdgeInsets(top: 32, left: 15, bottom: .zero, right: 15)
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
  }
  
  private let editBoardButton = UIButton().then {
    $0.layer.cornerRadius = 25
    $0.backgroundColor = .hex79BD9A
    $0.setImage(UIImage(named: "editButton"), for: .normal)
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.16).cgColor
    $0.layer.shadowOpacity = 1
    $0.layer.shadowRadius = 5
    $0.layer.shadowOffset = CGSize(width: 0, height: 8)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 25
  }
  
  init(type: BoardType, viewModel: BoardListViewModelType = BoardListViewModel()) {
    self.viewModel = viewModel
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set CollectionView delegate & dataSource
    boardListCollectionView.delegate = self
    boardListCollectionView.dataSource = self
    
    /// Set Navigationbar
    setupBackButton()
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [boardListCollectionView, editBoardButton].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    editBoardButton.snp.makeConstraints {
      $0.size.equalTo(50)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-54)
      $0.trailing.equalToSuperview().inset(15)
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireBoardList(boardType: type)
    
    viewModel.boardListModel
      .drive(rx.boardListModel)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, isLoading in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
  }
  
  @objc func didTappedBackButton() {
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
    let vc = BoardDetailViewController(boardType: type, boardSeq: boardListModel[indexPath.row].boardSeq)
    vc.navigationItem.largeTitleDisplayMode = .never
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
