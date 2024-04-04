//
//  StudyRoomDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import Kingfisher
import RxCocoa
import SnapKit
import SkeletonView
import Then

final class StudyRoomDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: StudyRoomDetailViewModelType
  private let roomSeq: Int
  
  private let studyRoomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.isUserInteractionEnabled = true
  }
  
  private let button = UIButton()
  
  private lazy var studyRoomDetailView = RothemRoomDetailView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.backgroundColor = .white
    $0.isSkeletonable = true
    $0.delegate = self
  }
  
  init(roomSeq: Int, viewModel: StudyRoomDetailViewModelType = StudyRoomDetailViewModel()) {
    self.roomSeq = roomSeq
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotification()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupBackButton()
    setupSkeletonView()
    registerNotification()
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [studyRoomImageView, studyRoomDetailView].forEach { view.addSubview($0) }
    studyRoomImageView.addSubview(button)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    studyRoomDetailView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo((((UIScreen.main.bounds.height - UINavigationController().navigationBar.frame.height) / 3) * 2))
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
    
    viewModel.inquireRothemRoomInfo(roomSeq: roomSeq)
    
    
    Driver.combineLatest(
      viewModel.rothemRoomDetailViewModel,
      viewModel.rothemRoomThumbnailImage
    )
    .drive(with: self) { owner, result in
      let (rothemRoomDetailViewModel, thumbnailImageURL) = result
      
      owner.view.hideSkeleton()
      
      owner.studyRoomDetailView.configureUI(with: rothemRoomDetailViewModel)
      owner.studyRoomImageView.kf.setImage(with: thumbnailImageURL)
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
    
    button.rx.tap
      .subscribe(with: self) { owner, _ in
        let modal = ZoomImageViewController(zoomImage: owner.studyRoomImageView.image!)
        modal.modalPresentationStyle = .fullScreen
        owner.present(modal, animated: true)
      }
      .disposed(by: disposeBag)

  }
}

extension StudyRoomDetailViewController: RothemRoomDetailViewDelegate {
  func didTappedReservationButton() {
    let vc = StudyReservationViewController(viewModel: StudyReservationViewModel(roomSeq: roomSeq))
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension StudyRoomDetailViewController {
  private func registerNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.inquireRothemRoomInfo(roomSeq: roomSeq)
  }
}
