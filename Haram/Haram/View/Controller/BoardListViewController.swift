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
  private lazy var boardListCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.backgroundColor = .systemBackground
    $0.register(BoardListCollectionViewCell.self, forCellWithReuseIdentifier: BoardListCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
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
    
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension BoardListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardListCollectionViewCell.identifier, for: indexPath) as? BoardListCollectionViewCell ?? BoardListCollectionViewCell()
    cell.configureUI(with: .init(title: "게시판제목", subTitle: "게시판부제목"))
    return cell
  }
}

extension BoardListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 92)
  }
}
