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
  var isLoading: Driver<Bool> { get }
}

final class CheckReservationViewModel {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository
  
  private var reservationSeq: Int?
  private let rothemReservationInfoViewRelay  = PublishRelay<RothemReservationInfoViewModel>()
  private let successCancelReservationSubject = PublishSubject<Void>()
  private let isLoadingSubject                = PublishSubject<Bool>()
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
    inquireRothemReservationInfo()
  }
  
  private func inquireRothemReservationInfo() {
    let inquireRothemReservationInfo = rothemRepository.inquireRothemReservationInfo(userID: UserManager.shared.userID!)
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    inquireRothemReservationInfo
      .subscribe(with: self) { owner, response in
        let model = RothemReservationInfoViewModel(response: response)
        owner.rothemReservationInfoViewRelay.accept(model)
        owner.reservationSeq = response.reservationSeq
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
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
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}
