//
//  ChapelViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class ChapelViewController: BaseViewController {
  
  private let viewModel: ChapelViewModel
  
  private var chapelListModel: [ChapelCollectionViewCellModel] = []
  private var chapelDetailModel: [ChapelDetailInfoViewModel] = []
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.alignment = .fill
    $0.distribution = .fill
    $0.isSkeletonable = true
  }
  
  private let chapelDayView = ChapelDayView()
  private let chapelInfoView = ChapelDetailInfoView()
  private let chapelAlertView = ChapelAlertView()
  private let chapelListView = ChapelListView()
  
  init(viewModel: ChapelViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    let input = ChapelViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: owner.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        }
      }
      .disposed(by: disposeBag)
    
    Observable.combineLatest(
      output.chapelConfirmationDays,
      output.chapelListModel,
      output.chapelDetailModel
    )
    .subscribe(with: self) { owner, result in
      let (confirmationDays, listModel, detailModel) = result
      owner.chapelListModel = listModel
      owner.chapelDetailModel = detailModel
      
      owner.view.hideSkeleton()
      
      owner.chapelListView.chapelCollectionView.reloadData()
      owner.chapelInfoView.chapelDetailInfoView.reloadData()
      
      owner.chapelDayView.configureUI(with: confirmationDays)
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
    chapelInfoView.chapelDetailInfoView.dataSource = self
  }
}

extension ChapelViewController {
  private func bindNotificationCenter(input: ChapelViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension ChapelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == chapelListView.chapelCollectionView {
      return chapelListModel.count
    } else if collectionView == chapelInfoView.chapelDetailInfoView {
      return chapelDetailModel.count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == chapelListView.chapelCollectionView {
      let cell = collectionView.dequeueReusableCell(ChapelCollectionViewCell.self, for: indexPath) ?? ChapelCollectionViewCell()
      cell.configureUI(with: chapelListModel[indexPath.row])
      return cell
    } else if collectionView == chapelInfoView.chapelDetailInfoView {
      let cell = collectionView.dequeueReusableCell(ChapelDetailCell.self, for: indexPath) ?? ChapelDetailCell()
      let item = chapelDetailModel[indexPath.row]
      cell.configureUI(with: .init(title: item.title, day: item.day))
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
    } else if skeletonView == chapelInfoView.chapelDetailInfoView {
      return ChapelDetailCell.reuseIdentifier
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
    if skeletonView == chapelInfoView.chapelDetailInfoView {
      return 5
    }
    return 10
  }
}

extension ChapelViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
