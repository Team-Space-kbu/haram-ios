//
//  LibraryResultsViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class LibraryResultsViewController: BaseViewController {
  
  private var model: [LibraryResultsCollectionViewCellModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(LibraryResultsCollectionViewCell.self, forCellWithReuseIdentifier: LibraryResultsCollectionViewCell.identifier)
    $0.register(LibraryResultsCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryResultsCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func updateData(model: [LibraryResultsCollectionViewCellModel]) {
    self.model = model
  }
}

extension LibraryResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return model.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryResultsCollectionViewCell.identifier, for: indexPath) as? LibraryResultsCollectionViewCell ?? LibraryResultsCollectionViewCell()
    cell.configureUI(with: model[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: collectionView.frame.width - 30,
      height: 112 + 15 + 1
    )
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LibraryResultsCollectionHeaderView.identifier, for: indexPath) as? LibraryResultsCollectionHeaderView ?? LibraryResultsCollectionHeaderView()
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 23 + 15)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("탭")
    let vc = LibraryDetailViewController()
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: true)
  }
}
