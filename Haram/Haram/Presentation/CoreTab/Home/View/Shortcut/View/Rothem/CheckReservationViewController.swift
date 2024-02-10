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
  
  private let reservationCancelButton = UIButton().then {
    $0.titleLabel?.font = .bold14
    $0.setTitle("예약취소하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .hex79BD9A
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.isSkeletonable = true
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
        owner.viewModel.cancelReservation()
      }
      .disposed(by: disposeBag)
    
    viewModel.successCancelReservation
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}
