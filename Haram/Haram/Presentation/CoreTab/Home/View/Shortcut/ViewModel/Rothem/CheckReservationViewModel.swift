//
//  CheckReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/27/23.
//

import RxSwift
import RxCocoa

protocol CheckReservationViewModelType {
  
  func cancelReservation()
  
  var rothemReservationInfoViewModel: Driver<RothemReservationInfoViewModel> { get }
  var successCancelReservation: Driver<Void> { get }
}

final class CheckReservationViewModel {
  
  private let disposeBag = DisposeBag()
  
  private var reservationSeq: Int?
  private let rothemReservationInfoViewRelay  = PublishRelay<RothemReservationInfoViewModel>()
  private let successCancelReservationSubject = PublishSubject<Void>()
  
  init() {
    inquireRothemReservationInfo()
  }
  
  private func inquireRothemReservationInfo() {
    let inquireRothemReservationInfo = RothemService.shared.inquireRothemReservationInfo(userID: UserManager.shared.userID!)
    
    inquireRothemReservationInfo
      .subscribe(with: self) { owner, response in
        let model = RothemReservationInfoViewModel(response: response)
        owner.rothemReservationInfoViewRelay.accept(model)
        owner.reservationSeq = response.reservationSeq
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
  func cancelReservation() {
    
    guard let reservationSeq = reservationSeq else { return }
    
    RothemService.shared.cancelRothemReservation(
      request: .init(
        reservationSeq: reservationSeq,
        userID: UserManager.shared.userID!
      )
    )
    .subscribe(with: self) { owner, _ in
      owner.successCancelReservationSubject.onNext(())
    }
    .disposed(by: disposeBag)
  }
  
  var successCancelReservation: RxCocoa.Driver<Void> {
    successCancelReservationSubject.asDriver(onErrorDriveWith: .empty())
  }
  
  var rothemReservationInfoViewModel: Driver<RothemReservationInfoViewModel> {
    rothemReservationInfoViewRelay.asDriver(onErrorDriveWith: .empty())
  }
  
}
