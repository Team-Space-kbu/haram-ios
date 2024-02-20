//
//  NoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/28.
//

import UIKit

import SnapKit
import Then

final class NoticeViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: NoticeViewModelType
  
  private var noticeModel: [NoticeCollectionViewCellModel] = [] {
    didSet {
      noticeCollectionView.reloadData()
    }
  }
  
  private var noticeTagModel: [MainNoticeType] = [] {
    didSet {
      noticeCollectionView.reloadData()
    }
  }
  
  private lazy var noticeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return type(of: self).setCollectionViewSection()
    }
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self, forCellWithReuseIdentifier: NoticeCollectionViewCell.identifier)
    $0.register(NoticeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NoticeCollectionHeaderView.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .always
  }
  
  init(viewModel: NoticeViewModelType = NoticeViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.noticeModel
      .drive(rx.noticeModel)
      .disposed(by: disposeBag)
    
    viewModel.noticeTagModel
      .drive(rx.noticeTagModel)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(resource: .searchLightGray),
      style: .plain,
      target: self,
      action: #selector(didTappedSearch)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(noticeCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    noticeCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  static private func setCollectionViewSection() -> NSCollectionLayoutSection? {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      )
    )
    
    let verticalGroup = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(92)
      ),
      subitems: [item]
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(189 + 30)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )

    let section = NSCollectionLayoutSection(group: verticalGroup)
    section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 15, bottom: 15, trailing: 15)
    section.interGroupSpacing = 20
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  @objc private func didTappedSearch() {
    
  }
}

extension NoticeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return noticeModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionViewCell.identifier, for: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
    cell.configureUI(with: noticeModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NoticeCollectionHeaderView.identifier, for: indexPath) as? NoticeCollectionHeaderView ?? NoticeCollectionHeaderView()
    header.delegate = self
    header.configureUI(with: noticeTagModel)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = NoticeDetailViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension NoticeViewController: NoticeCollectionHeaderViewDelegate {
  func didTappedCategory(noticeType: NoticeType) {
    let vc = SelectedCategoryNoticeViewController(noticeType: noticeType)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}
