//
//  ChapelViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import RxCocoa
import SnapKit
import SkeletonView
import Then

final class ChapelViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: ChapelViewModelType
  
  private var chapelHeaderModel: ChapelCollectionHeaderViewModel?
  
  private var chapelListModel: [ChapelCollectionViewCellModel] = []
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.alignment = .fill
    $0.distribution = .fill
  }
  
  private let chapelDayView = ChapelDayView()
  private let chapelInfoView = ChapelDetailInfoView()
  private let chapelAlertView = ChapelAlertView()
  private let chapelListView = ChapelListView()
  
  init(viewModel: ChapelViewModelType = ChapelViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireChapelInfo()
    
    viewModel.chapelHeaderModel
      .drive(with: self) { owner, chapelHeaderModel in
        owner.chapelHeaderModel = chapelHeaderModel
        owner.viewModel.inquireChapelDetail()
      }
      .disposed(by: disposeBag)
    
    viewModel.chapelListModel
      .drive(with: self) { owner, chapelListModel in
        owner.chapelListModel = chapelListModel
        
        owner.view.hideSkeleton()
        
        owner.chapelListView.chapelCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    viewModel.chapelDetailModel
      .drive(chapelInfoView.chapelDetailInfoView.rx.items(
            cellIdentifier: ChapelDetailCell.reuseIdentifier,
            cellType: ChapelDetailCell.self)
        ) { index, item, cell in
        cell.configureUI(with: .init(title: item.title, day: item.day))
        }
        .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .requiredStudentID {
          let vc = IntranetCheckViewController()
          vc.navigationItem.largeTitleDisplayMode = .never
          owner.navigationController?.pushViewController(vc, animated: true)
        } else if error == .networkError {
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
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [chapelDayView, chapelInfoView, chapelAlertView, chapelListView]
    containerView.addArrangedDividerSubViews(subViews, exclude: [0], thickness: 10)
  }
  
  override func setupConstraints() {
    super.setupConstraints()  
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "채플조회"
    setupBackButton()
    setupSkeletonView()
    
    chapelListView.chapelCollectionView.delegate = self
    chapelListView.chapelCollectionView.dataSource = self
  }
  
  @objc func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension ChapelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == chapelListView.chapelCollectionView {
      return chapelListModel.count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == chapelListView.chapelCollectionView {
      let cell = collectionView.dequeueReusableCell(ChapelCollectionViewCell.self, for: indexPath) ?? ChapelCollectionViewCell()
      cell.configureUI(with: chapelListModel[indexPath.row])
      return cell
    }
    return UICollectionViewCell()
  }
}

extension ChapelViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == chapelListView.chapelCollectionView {
      return CGSize(width: collectionView.bounds.width, height: 44)
    }
    return .zero
  }
}

extension ChapelViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    if skeletonView == chapelListView.chapelCollectionView {
      return ChapelCollectionViewCell.reuseIdentifier
    }
    return ""
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == chapelListView.chapelCollectionView {
      let cell = skeletonView.dequeueReusableCell(ChapelCollectionViewCell.self, for: indexPath)
      cell?.configureUI(with: .init(chapelResult: .absence))
      return cell
    }
    return nil
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
}

extension ChapelViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension ChapelViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.inquireChapelInfo()
  }
}
