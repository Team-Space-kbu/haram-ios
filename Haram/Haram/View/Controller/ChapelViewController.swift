//
//  ChapelViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

final class ChapelViewController: BaseViewController {
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 19.5
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hex9F9FA4
  }
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hex9F9FA4
  }
  
  private let chapelDayView = ChapelDayView()
  
  private let chapelInfoView = ChapelInfoView()
  
  private lazy var chapelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
  }).then {
    $0.register(ChapelCollectionViewCell.self, forCellWithReuseIdentifier: ChapelCollectionViewCell.identifier)
    $0.register(ChapelCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapelCollectionHeaderView.identifier)
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .systemBackground
    $0.contentInset = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerStackView)
    [chapelDayView, lineView, chapelInfoView, lineView1, chapelCollectionView].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    chapelInfoView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(57)
      $0.height.equalTo(46)
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview().inset(30)
    }
    
    lineView1.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview().inset(30)
    }
    
    chapelCollectionView.snp.makeConstraints {
      $0.height.equalTo(UIScreen.main.bounds.height - 320)
    }
    
    containerStackView.setCustomSpacing(72, after: chapelDayView)
  }
  
  override func setupStyles() {
    super.setupStyles()
    chapelDayView.configureUI(with: 50)
  }
}

extension ChapelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapelCollectionViewCell.identifier, for: indexPath) as? ChapelCollectionViewCell ?? ChapelCollectionViewCell()
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChapelCollectionHeaderView.identifier, for: indexPath) as? ChapelCollectionHeaderView ?? ChapelCollectionHeaderView()
    return header
  }
}

extension ChapelViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width - 30, height: 44)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 28 + 14)
  }
}
