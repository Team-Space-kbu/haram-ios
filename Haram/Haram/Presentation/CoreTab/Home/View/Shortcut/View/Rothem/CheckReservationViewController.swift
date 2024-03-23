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

final class CheckReservationViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: CheckReservationViewModelType
  
  private let rothemReservationInfoView = RothemReservationInfoView().then {
    $0.isSkeletonable = true
  }
  
  private let reservationCancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약취소하기", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  init(viewModel: CheckReservationViewModelType = CheckReservationViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "예약확인하기"
    setupBackButton()
    setupSkeletonView()
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
      $0.width.equalTo(141)
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(58)
      $0.centerX.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.rothemReservationInfoViewModel
      .drive(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.rothemReservationInfoView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
    
    reservationCancelButton.rx.tap
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(with: self) { owner, _ in
        AlertManager.showAlert(
          title: "로뎀예약취소 알림",
          message: "정말 로뎀방 예약을 취소하시겠습니까 ?",
          viewController: owner,
          confirmHandler: {
            owner.viewModel.cancelReservation()
          },
          cancelHandler: nil
        )
      }
      .disposed(by: disposeBag)
    
    viewModel.successCancelReservation
      .drive(with: self) { owner, _ in
        NotificationCenter.default.post(name: .refreshRothemList, object: nil)
        AlertManager.showAlert(title: "로뎀예약취소 성공", message: "로뎀메인화면으로 이동합니다.", viewController: owner) { owner.navigationController?.popViewController(animated: true) }
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
            owner.navigationController?.popViewController(animated: true)
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}
