//
//  CheckReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/27/23.
//

import RxSwift
import RxCocoa

protocol CheckReservationViewModelType {
  var requestCancelReservation: AnyObserver<Void> { get }
  
  var rothemReservationInfoViewModel: Driver<RothemReservationInfoViewModel> { get }
  var successCancelReservation: Signal<Void> { get }
}

final class CheckReservationViewModel {
  
  private let disposeBag = DisposeBag()
  
  private var reservationSeq: Int?
  private let rothemReservationInfoViewRelay  = PublishRelay<RothemReservationInfoViewModel>()
  private let cancelReservationSubject        = PublishSubject<Void>()
  private let successCancelReservationSubject = PublishSubject<Void>()
  
  init() {
    inquireRothemReservationInfo()
    cancelReservation()
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
  
  private func cancelReservation() {
    
    cancelReservationSubject
      .withUnretained(self)
      .flatMapLatest { owner, _ in
        RothemService.shared.cancelRothemReservation(
          request: .init(
            reservationSeq: owner.reservationSeq!,
            userID: UserManager.shared.userID!
          )
        ) }
      .subscribe(with: self) { owner, _ in
        owner.successCancelReservationSubject.onNext(())
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  var successCancelReservation: RxCocoa.Signal<Void> {
    successCancelReservationSubject.asSignal(onErrorSignalWith: .empty())
  }
  
  var rothemReservationInfoViewModel: Driver<RothemReservationInfoViewModel> {
    rothemReservationInfoViewRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var requestCancelReservation: AnyObserver<Void> {
    cancelReservationSubject.asObserver()
  }
}
