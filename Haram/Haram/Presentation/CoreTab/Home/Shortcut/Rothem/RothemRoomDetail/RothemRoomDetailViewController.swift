//
//  StudyRoomDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import Kingfisher
import RxSwift
import SnapKit
import SkeletonView
import Then

final class RothemRoomDetailViewController: BaseViewController {
  
  private let viewModel: RothemRoomDetailViewModel
  
  private let studyRoomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.isUserInteractionEnabled = true
  }
  
  private let button = UIButton()
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .clear
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.16).cgColor
    $0.layer.shadowOpacity = 1
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: -3)
    $0.isSkeletonable = true
  }
  
  private let studyRoomDetailView = RothemRoomDetailView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.backgroundColor = .white
    $0.isSkeletonable = true
  }
  
  init(viewModel: RothemRoomDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotification()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupBackButton()
    setupSkeletonView()
    studyRoomDetailView.popularAmenityCollectionView.delegate = self
    studyRoomDetailView.popularAmenityCollectionView.dataSource = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [studyRoomImageView, backgroundView].forEach { view.addSubview($0) }
    backgroundView.addSubview(studyRoomDetailView)
    studyRoomImageView.addSubview(button)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo((((UIScreen.main.bounds.height - UINavigationController().navigationBar.frame.height) / 3) * 2))
    }
    
    studyRoomDetailView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    studyRoomImageView.snp.makeConstraints {
      $0.topMargin.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(studyRoomDetailView.snp.top).offset(40)
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = RothemRoomDetailViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didTapReservationButton: studyRoomDetailView.reservationButton.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    Observable.combineLatest(
      output.currentRothemRoomDetailViewModel,
      output.currentRothemRoomThubnailImage
    )
    .subscribe(with: self) { owner, result in
      let (rothemRoomInfo, thumbnailImageURL) = result
      
      owner.view.hideSkeleton()
      
      owner.studyRoomDetailView.configureUI(
        roomTitle: rothemRoomInfo.roomTitle,
        roomDestination: rothemRoomInfo.roomDestination,
        roomDescription: rothemRoomInfo.roomDescription
      )
      owner.studyRoomImageView.kf.setImage(with: thumbnailImageURL)
      owner.studyRoomDetailView.popularAmenityCollectionView.reloadData()
    }
    .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
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
    
    button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.studyRoomImageView.showAnimation(scale: 0.98) {
          if let zoomImage = owner.studyRoomImageView.image {
            let modal = ZoomImageViewController(zoomImage: zoomImage)
            modal.modalPresentationStyle = .fullScreen
            owner.present(modal, animated: true)
          } else {
            AlertManager.showAlert(title: "이미지 확대 알림", message: "해당 이미지는 확대할 수 없습니다", viewController: owner, confirmHandler: nil)
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension RothemRoomDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.amenityModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(PopularAmenityCollectionViewCell.self, for: indexPath) ?? PopularAmenityCollectionViewCell()
    cell.configureUI(with: viewModel.amenityModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard !viewModel.amenityModel.isEmpty else {
      return CGSize(width: 48, height: 56)
    }
    
    let label = UILabel().then {
      $0.font = .regular12
      $0.text = viewModel.amenityModel[indexPath.row].amenityContent
      $0.sizeToFit()
    }
    return CGSize(width: label.frame.width, height: 56)
  }
}

extension RothemRoomDetailViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    PopularAmenityCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? { skeletonView.dequeueReusableCell(PopularAmenityCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.amenityModel.count
  }
}

extension RothemRoomDetailViewController {
  private func registerNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    //    viewModel.inquireRothemRoomInfo(roomSeq: roomSeq)
  }
}
