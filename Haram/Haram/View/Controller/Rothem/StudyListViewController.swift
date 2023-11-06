//
//  StudyListViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class StudyListViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let viewModel: StudyListViewModelType
  private var type: StudyListCollectionHeaderViewType = .noReservation
  
  // MARK: - UI Models
  
  private var studyListModel: [StudyListCollectionViewCellModel] = [] {
    didSet {
      studyListCollectionView.reloadData()
    }
  }
  
  private var rothemMainNoticeModel: StudyListHeaderViewModel? {
    didSet {
      studyListCollectionView.reloadData()
    }
  }
  
  // MARK: - UI Components
  
  private lazy var studyListCollectionView = UICollectionView(
    frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
  }).then {
    $0.register(StudyListCollectionViewCell.self, forCellWithReuseIdentifier: StudyListCollectionViewCell.identifier)
    $0.register(StudyListCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StudyListCollectionHeaderView.identifier)
    $0.backgroundColor = .clear
    $0.delegate = self
    $0.dataSource = self
    $0.isSkeletonable = true
    $0.alwaysBounceVertical = true
    $0.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 15, right: .zero)
  }
  
  // MARK: - Initializations
  
  init(viewModel: StudyListViewModelType = StudyListViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
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
    
    viewModel.currentRothemMainNotice
      .drive(rx.rothemMainNoticeModel)
      .disposed(by: disposeBag)
    
    viewModel.isReservation
      .drive(rx.type)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, isLoading in
        owner.studyListCollectionView.reloadData()
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Configure NavigationBar
    title = "스터디"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    /// Configure Skeleton
    view.isSkeletonable = true
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)

    let graient = SkeletonGradient(baseColor: .skeletonDefault)
    view.showAnimatedGradientSkeleton(
      usingGradient: graient,
      animation: skeletonAnimation,
      transition: .none
    )
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension StudyListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = StudyRoomDetailViewController(viewModel: StudyRoomDetailViewModel(roomSeq: studyListModel[indexPath.row].roomSeq))
    vc.title = studyListModel[indexPath.row].title
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

extension StudyListViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    StudyListCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: StudyListCollectionViewCell.identifier, for: indexPath) as? StudyListCollectionViewCell ?? StudyListCollectionViewCell()
    cell.configureUI(with: .init(rothemRoom: .init(roomSeq: -1, thumbnailImage: "", roomName: "Lorem ipsum dolor sit amet", roomExplanation: "Lorem ipsum dolor sit amet, consetetur\nsadipscing elitr, sed diam nonumy", peopleCount: 0, location: "1234")))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    studyListModel.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudyListCollectionViewCell.identifier, for: indexPath) as? StudyListCollectionViewCell ?? StudyListCollectionViewCell()
    cell.configureUI(with: studyListModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: StudyListCollectionHeaderView.identifier,
      for: indexPath
    ) as? StudyListCollectionHeaderView ?? StudyListCollectionHeaderView()
    header.configureUI(with: rothemMainNoticeModel, type: type)
    header.delegate = self
    return header
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    StudyListCollectionHeaderView.identifier
  }
}
