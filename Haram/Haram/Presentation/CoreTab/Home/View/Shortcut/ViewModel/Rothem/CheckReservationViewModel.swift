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
  func inquireRothemReservationInfo()
  
  var rothemReservationInfoViewModel: Driver<RothemReservationInfoViewModel> { get }
  var successCancelReservation: Driver<Void> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class CheckReservationViewModel {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository
  
  private var reservationSeq: Int?
  private let rothemReservationInfoViewRelay  = PublishRelay<RothemReservationInfoViewModel>()
  private let successCancelReservationSubject = PublishSubject<Void>()
  private let errorMessageRelay               = BehaviorRelay<HaramError?>(value: nil)
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
  func inquireRothemReservationInfo() {
    let inquireRothemReservationInfo = rothemRepository.inquireRothemReservationInfo(userID: UserManager.shared.userID!)
    
    inquireRothemReservationInfo
      .subscribe(with: self, onSuccess: { owner, response in
        let model = RothemReservationInfoViewModel(response: response)
        owner.rothemReservationInfoViewRelay.accept(model)
        owner.reservationSeq = response.reservationSeq
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        print("에러 \(error)")
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  func cancelReservation() {
    
    guard let reservationSeq = reservationSeq else { return }
    
    rothemRepository.cancelRothemReservation(
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
