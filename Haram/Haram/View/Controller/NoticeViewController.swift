//
//  NoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/28.
//

import UIKit

import SnapKit
import Then

enum CategorySectionType: CaseIterable {
  case haramNotice // 하람공지
  case haksa // 학사/취창업
  case scholarShip // 장학/등록금
  case chapel // 신앙/채플
  case lmsNotice // LMS 공지
  case library // 도서관
  case aiNavi // AI NAVI
  
  var title: String {
    switch self {
    case .haramNotice:
      return "하람공지"
    case .haksa:
      return "학사/취창업"
    case .scholarShip:
      return "장학/등록금"
    case .chapel:
      return "신앙/채플"
    case .lmsNotice:
      return "LMS공지"
    case .library:
      return "도서관"
    case .aiNavi:
      return "AI NAVI"
    }
  }
}

final class NoticeViewController: BaseViewController {
  
  private let viewModel: NoticeViewModelType
  
  private var noticeModel: [NoticeCollectionViewCellModel] = [] {
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
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "searchLightGray"),
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
  
  static func setCollectionViewSection() -> NSCollectionLayoutSection? {
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
        heightDimension: .absolute(20 + 200 + 20 + 22 + 70)
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
  
  @objc private func didTappedBackButton() {
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
    return header
  }
}
