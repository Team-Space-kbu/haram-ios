//
//  BoardListViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/07/30.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class BoardListViewController: BaseViewController {
  
  private let viewModel: BoardListViewModelType
  private let type: BoardType
  
  private var boardListModel: [BoardListCollectionViewCellModel] = [] {
    didSet {
      var snapshot = NSDiffableDataSourceSnapshot<Section, BoardListCollectionViewCellModel>()
      snapshot.appendSections([.main])
      snapshot.appendItems(boardListModel)
      self.dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
  private var dataSource: UICollectionViewDiffableDataSource<Section, BoardListCollectionViewCellModel>!
  
  private lazy var boardListCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .clear
    $0.register(BoardListCollectionViewCell.self, forCellWithReuseIdentifier: BoardListCollectionViewCell.identifier)
    $0.delegate = self
    $0.contentInset = UIEdgeInsets(top: 32, left: 15, bottom: .zero, right: 15)
  }
  
  init(viewModel: BoardListViewModelType = BoardListViewModel(), type: BoardType) {
    self.viewModel = viewModel
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    let cellRegistration = UICollectionView.CellRegistration<BoardListCollectionViewCell, BoardListCollectionViewCellModel> { cell, indexPath, item in
      cell.configureUI(with: item)
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, BoardListCollectionViewCellModel>(collectionView: boardListCollectionView) { collectionView, indexPath, item -> UICollectionViewCell in
      return collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration,
        for: indexPath,
        item: item
      )
    }
    
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(boardListCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.whichBoardType.onNext(type)
    
    viewModel.boardListModel
      .drive(rx.boardListModel)
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = BoardDetailViewController(boardSeq: boardListModel[indexPath.row].boardSeq, boardType: type)
    vc.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - Section For DiffableDataSource

extension BoardListViewController {
  enum Section: CaseIterable {
    case main
    case second
  }
}
