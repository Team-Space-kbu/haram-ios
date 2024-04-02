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
import RxCocoa

final class RothemRoomListViewController: BaseViewController, BackButtonHandler {
  
  // MARK: - Properties
  
  private let viewModel: RothemRoomListViewModelType
  private var mainNoticeSeq: Int?
  private var type: StudyListCollectionHeaderViewType = .noReservation {
    didSet {
      studyListCollectionView.reloadData()
    }
  }
  
  // MARK: - UI Models
  
  private var studyListModel: [StudyListCollectionViewCellModel] = []
  
  private var rothemMainNoticeModel: StudyListHeaderViewModel?
  
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
  
  private lazy var emptyView = EmptyView(text: "예약가능한 방이 존재하지 않습니다.").then {
    $0.backgroundColor = .white
  }
  
  // MARK: - Initializations
  
  init(viewModel: RothemRoomListViewModelType = RothemRoomListViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(studyListCollectionView)
    view.addSubview(emptyView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    studyListCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    emptyView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.inquireRothemRoomList()
    
    Driver.combineLatest(
      viewModel.currentStudyReservationList,
      viewModel.currentRothemMainNotice,
      viewModel.isReservation
    )
    .drive(with: self) { owner, result in
      let (studyListModel, rothemMainNoticeModel, type) = result
      owner.studyListModel = studyListModel
      owner.rothemMainNoticeModel = rothemMainNoticeModel
      owner.type = type
      owner.mainNoticeSeq = rothemMainNoticeModel?.noticeSeq
      
      owner.view.hideSkeleton()
      
      
      owner.emptyView.isHidden = !studyListModel.isEmpty
      
      owner.studyListCollectionView.reloadData()
    }
    .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Configure NavigationBar
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    title = "스터디"
    setupBackButton()
    
    setupSkeletonView()
    registerNotifications()
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension RothemRoomListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as? StudyListCollectionViewCell ?? StudyListCollectionViewCell()
    cell.showAnimation(scale: 0.9) { [weak self] in
      guard let self = self else { return }
      let vc = StudyRoomDetailViewController(roomSeq: studyListModel[indexPath.row].roomSeq)
      vc.title = studyListModel[indexPath.row].title
      vc.navigationItem.largeTitleDisplayMode = .never
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }  
}

extension RothemRoomListViewController: UICollectionViewDelegateFlowLayout {
  
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
    CGSize(width: collectionView.frame.width - 30, height: 98)
  }
}

extension RothemRoomListViewController: StudyListCollectionHeaderViewDelegate {
  func didTappedRothemNotice() {
    let vc = RothemNoticeDetailViewController(noticeSeq: mainNoticeSeq!)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTappedCheckButton() {
    let vc = CheckReservationViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension RothemRoomListViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    StudyListCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: StudyListCollectionViewCell.identifier, for: indexPath) as? StudyListCollectionViewCell ?? StudyListCollectionViewCell()
    cell.configureUI(with: .init(rothemRoom: .init(roomSeq: -1, location: "", thumbnailPath: "", roomName: "Lorem ipsum dolor sit amet", roomExplanation: "Lorem ipsum dolor sit amet, consetetur\nsadipscing elitr, sed diam nonumy", peopleCount: 0, createdBy: "", createdAt: "", modifiedBy: "", modifiedAt: ""), isLast: false))
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

extension RothemRoomListViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension RothemRoomListViewController {
  func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshRothemList), name: .refreshRothemList, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(refreshRothemList), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func refreshRothemList() {
    viewModel.inquireRothemRoomList()
  }
}

