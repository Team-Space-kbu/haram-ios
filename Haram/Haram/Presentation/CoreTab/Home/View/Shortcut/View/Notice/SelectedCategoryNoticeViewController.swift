//
//  SelectedCategoryNoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 1/17/24.
//

import UIKit

import SnapKit
import Then

final class SelectedCategoryNoticeViewController: BaseViewController {
  
  private let noticeType: NoticeType
  
  private var noticeModel: [NoticeCollectionViewCellModel] = [] {
    didSet {
      noticeCollectionView.reloadData()
    }
  }
  
  private lazy var noticeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self, forCellWithReuseIdentifier: NoticeCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .always
  }
  
  init(noticeType: NoticeType) {
    self.noticeType = noticeType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
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
}

extension SelectedCategoryNoticeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let vc = NoticeDetailViewController()
//    vc.navigationItem.largeTitleDisplayMode = .never
//    navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectedCategoryNoticeViewController: UICollectionViewDataSource {
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
}

extension SelectedCategoryNoticeViewController: BackButtonHandler {
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
