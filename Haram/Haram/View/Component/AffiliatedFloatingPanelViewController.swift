//
//  AffiliatedFloatingPanelViewController.swift
//  Haram
//
//  Created by 이건준 on 11/15/23.
//

import UIKit

import SnapKit
import Then

protocol AffiliatedFloatingPanelDelegate: AnyObject {
  func didTappedAffiliatedCollectionViewCell(_ model: AffiliatedCollectionViewCellModel)
}

final class AffiliatedFloatingPanelViewController: BaseViewController {
  
  weak var delegate: AffiliatedFloatingPanelDelegate?
  var touchHandler: ((Int) -> Void)?
  
  private let affiliatedModel: [AffiliatedCollectionViewCellModel]
  
  init(affiliateModel: [AffiliatedCollectionViewCellModel]) {
    self.affiliatedModel = affiliateModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let affiliatedCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumLineSpacing = 21
    }
  ).then {
    $0.register(AffiliatedCollectionViewCell.self, forCellWithReuseIdentifier: AffiliatedCollectionViewCell.identifier)
    $0.backgroundColor = .white
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 25, left: 15, bottom: 15, right: 15)
    $0.isScrollEnabled = true
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set CollectionView delegate & dataSource
    affiliatedCollectionView.delegate = self
    affiliatedCollectionView.dataSource = self
    
    touchHandler = { [weak self] row in
      guard let self = self else { return }
      self.scrollToItem(at: IndexPath(row: row, section: 0))
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(affiliatedCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    affiliatedCollectionView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(25)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension AffiliatedFloatingPanelViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return affiliatedModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AffiliatedCollectionViewCell.identifier, for: indexPath) as? AffiliatedCollectionViewCell ?? AffiliatedCollectionViewCell()
    cell.configureUI(with: affiliatedModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 109)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = affiliatedModel[indexPath.row]
    
    delegate?.didTappedAffiliatedCollectionViewCell(model)
    scrollToItem(at: indexPath)
  }
  
  /// 특정 인덱스로 스크롤하는 함수
  private func scrollToItem(at indexPath: IndexPath) {
    self.affiliatedCollectionView.isPagingEnabled = false
    self.affiliatedCollectionView.scrollToItem(
      at: indexPath,
      at: .top,
      animated: true
    )
    self.affiliatedCollectionView.isPagingEnabled = true
  }
}
