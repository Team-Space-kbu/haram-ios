//
//  CheckReservationViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import SkeletonView
import Then
import RxSwift

final class CheckReservationViewController: BaseViewController {
  
  private let viewModel: CheckReservationViewModel
  private let requestCancelReservation = PublishSubject<Void>()
  
  private let rothemReservationInfoView = RothemReservationInfoView().then {
    $0.isSkeletonable = true
  }
  
  private let reservationCancelButton = UIButton(configuration: .plain()).then {
    $0.configuration?.baseBackgroundColor = .clear
    $0.configuration?.baseForegroundColor = .hex3B8686
    let fontAttribute = [NSAttributedString.Key.font: UIFont.bold16]
    let attributedTitle = NSAttributedString(string: "예약 취소하기", attributes: fontAttribute)
    $0.setAttributedTitle(attributedTitle, for: .normal)
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.background.strokeColor = .hex79BD9A
    $0.configuration?.background.strokeWidth = 1
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  init(viewModel: CheckReservationViewModel) {
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
    title = "예약정보"
    setupBackButton()
    setupSkeletonView()
    rothemReservationInfoView.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [rothemReservationInfoView, reservationCancelButton].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    rothemReservationInfoView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(158)
      $0.height.equalTo(466)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    reservationCancelButton.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(rothemReservationInfoView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(58)
    }
  }
  
  override func bind() {
    super.bind()
    let input = CheckReservationViewModel.Input(
      viewDidLoad: .just(()),
      didRequestCancelReservation: requestCancelReservation.asObservable(),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: self.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        }
      }
      .disposed(by: disposeBag)
    
    output.rothemReservationInfoView
      .subscribe(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.rothemReservationInfoView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
    
    reservationCancelButton.rx.tap
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(with: self) { owner, _ in
        AlertManager.showAlert(on: self.navigationController, message: .custom("정말 로뎀방 예약을 취소하시겠습니까 ?"), actions: [.confirm(), .cancel()], confirmHandler: {
          owner.requestCancelReservation.onNext(())
        })
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewController {
  private func registerNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    //    viewModel.inquireRothemReservationInfo()
  }
}

extension CheckReservationViewController: RothemReservationInfoViewDelegate {
  func didTappedQrCode(data: Data) {
    guard let zoomImage = UIImage(data: data) else { return }
    let modal = ZoomImageViewController(zoomImage: zoomImage)
    modal.modalPresentationStyle = .fullScreen
    present(modal, animated: true)
  }
  
  func didTappedBarCode(image: UIImage?) {
    if let zoomImage = image {
      let modal = ZoomImageViewController(zoomImage: zoomImage)
      modal.modalPresentationStyle = .fullScreen
      present(modal, animated: true)
    } else {
      AlertManager.showAlert(on: self.navigationController, message: .custom("해당 이미지는 확대할 수 없습니다"))
    }
  }
}
