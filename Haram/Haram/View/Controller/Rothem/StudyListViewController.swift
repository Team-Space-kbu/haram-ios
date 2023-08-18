//
//  StudyListViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import SnapKit
import Then

final class StudyListViewController: BaseViewController {
  
  private let viewModel: StudyListViewModelType
  private var type: StudyListCollectionHeaderViewType = .reservation
  
  private var studyListModel: [StudyListCollectionViewCellModel] = [] {
    didSet {
      updateCollectionViewSnapshot()
    }
  }
  private var studyHeaderModel: StudyListHeaderViewModel? {
    didSet {
      updateCollectionViewSnapshot()
    }
  }
  
  private var dataSource: UICollectionViewDiffableDataSource<Section, StudyListCollectionViewCellModel>!
  
  private lazy var studyListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
  }).then {
    $0.backgroundColor = .clear
    $0.delegate = self
  }
  
  init(viewModel: StudyListViewModelType = StudyListViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(studyListCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    studyListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.currentStudyReservationList
      .drive(rx.studyListModel)
      .disposed(by: disposeBag)
    
    viewModel.currentStudyReservationHeaderModel
      .drive(rx.studyHeaderModel)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    setCollectionViewDataSource()
    title = "스터디"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  private func setCollectionViewDataSource() {
    
    let cellRegistration = UICollectionView.CellRegistration<StudyListCollectionViewCell, StudyListCollectionViewCellModel> { cell, indexPath, item in
      cell.configureUI(with: item)
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<StudyListCollectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self = self else { return }
      switch self.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
      case .studyList(let studyHeaderModel):
        guard let studyHeaderModel = studyHeaderModel else { return }
        supplementaryView.delegate = self
        supplementaryView.configureUI(with: studyHeaderModel, type: self.type)
      }
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, StudyListCollectionViewCellModel>(collectionView: studyListCollectionView) { collectionView, indexPath, item -> UICollectionViewCell in
      return collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration,
        for: indexPath,
        item: item
      )
    }.then {
      $0.supplementaryViewProvider = .init { collectionView, _, indexPath in
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration,
          for: indexPath
        )
      }
    }
  }
  
  private func updateCollectionViewSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, StudyListCollectionViewCellModel>()
    snapshot.appendSections([.studyList(studyHeaderModel)])
    snapshot.appendItems(studyListModel)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
}

extension StudyListViewController {
  enum Section: Hashable {
    case studyList(StudyListHeaderViewModel?)
  }
}

extension StudyListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = StudyReservationViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension StudyListViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    /// 헤더뷰랑 로뎀스터디룸예약 라벨 사이의 간격을 모르겠음 30을 수정해야함
    switch type {
    case .noReservation:
      return CGSize(width: collectionView.frame.width, height: 22 + 26 + 294 + 26)
    case .reservation:
      return CGSize(width: collectionView.frame.width, height: 453.97 - 17.97)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width - 30, height: 98)
  }
}

extension StudyListViewController: StudyListCollectionHeaderViewDelegate {
  func didTappedCheckButton() {
    let vc = CheckReservationViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}
