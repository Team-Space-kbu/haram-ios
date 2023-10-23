//
//  BoardDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import Then

final class BoardDetailViewController: BaseViewController {
  
  private let viewModel: BoardDetailViewModelType
  private let boardSeq: Int
  private let boardType: BoardType
  
  private var cellModel: [BoardDetailCollectionViewCellModel] = [] {
    didSet {
      boardDetailCollectionView.reloadSections([1])
    }
  }
  
  private var boardModel: [BoardDetailHeaderViewModel] = [] {
    didSet {
      boardDetailCollectionView.reloadSections([0])
    }
  }
//  private var boardCommentModel:
  
  // MARK: - UI Component
  
  private lazy var boardDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return type(of: self).createCollectionViewLayout(sec: sec)
  }).then {
    $0.register(BoardDetailCollectionViewCell.self, forCellWithReuseIdentifier: BoardDetailCollectionViewCell.identifier)
    $0.register(BoardDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailHeaderView.identifier)
    $0.register(BoardDetailCommentHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailCommentHeaderView.identifier)
//    $0.delegate = self
    $0.dataSource = self
  }
  
  // MARK: - Initializations
  init(viewModel: BoardDetailViewModelType = BoardDetailViewModel(), boardSeq: Int, boardType: BoardType) {
    self.viewModel = viewModel
    self.boardSeq = boardSeq
    self.boardType = boardType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    title = "게시판"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(boardDetailCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardDetailCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.whichBoardSeq.onNext(boardSeq)
    viewModel.whichBoardType.onNext(boardType)
    
    viewModel.boardInfoModel
      .drive(rx.boardModel)
      .disposed(by: disposeBag)
    
    viewModel.boardCommentModel
      .drive(rx.cellModel)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Action Function
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - UICompositonalLayout Function
  
  static private func createCollectionViewLayout(sec: Int) -> NSCollectionLayoutSection? {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(35 + 3 + 18)
      )
    )
    
    let verticalGroup = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(35 + 3 + 18)
      ),
      subitems: [item]
    )
//    verticalGroup.interItemSpacing = .fixed(16)
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(18 + 3 + 18 + 16 + 18 + 6 + 18)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )

    let section = NSCollectionLayoutSection(group: verticalGroup)
    if sec == 1 {
      section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: 16, trailing: 16)
    }
    section.interGroupSpacing = 16
    section.boundarySupplementaryItems = [header]
    return section
  }
}

// MARK: - UICollectionDataSource

extension BoardDetailViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard section == 1 else { return 0 }
    return cellModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.section == 1 else { return UICollectionViewCell() }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardDetailCollectionViewCell.identifier, for: indexPath) as? BoardDetailCollectionViewCell ?? BoardDetailCollectionViewCell()
    cell.configureUI(with: cellModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: BoardDetailHeaderView.identifier,
        for: indexPath
      ) as? BoardDetailHeaderView ?? BoardDetailHeaderView()
      header.configureUI(with: boardModel.first)
      return header
    }
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: BoardDetailCommentHeaderView.identifier,
      for: indexPath
    ) as? BoardDetailCommentHeaderView ?? BoardDetailCommentHeaderView()
    return header
    
  }
  
}
