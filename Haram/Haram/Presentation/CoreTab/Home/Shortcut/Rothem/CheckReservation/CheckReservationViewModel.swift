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

final class CheckReservationViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private var reservationSeq: Int?
  
  struct Payload {
    
  }
  
  struct Dependency {
    let rothemRepository: RothemRepository
    let coordinator: CheckReservationCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didRequestCancelReservation: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    let rothemReservationInfoView  = PublishRelay<RothemReservationInfoViewModel>()
    let successCancelReservation = PublishSubject<Void>()
    let errorMessage               = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireRothemReservationInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didRequestCancelReservation
      .subscribe(with: self) { owner, _ in
        owner.cancelReservation(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension CheckReservationViewModel {
  
  func inquireRothemReservationInfo(output: Output) {
    let inquireRothemReservationInfo = dependency.rothemRepository.inquireRothemReservationInfo(userID: UserManager.shared.userID!)
    
    inquireRothemReservationInfo
      .subscribe(with: self, onSuccess: { owner, response in
        let model = RothemReservationInfoViewModel(response: response)
        output.rothemReservationInfoView.accept(model)
        owner.reservationSeq = response.reservationSeq
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func cancelReservation(output: Output) {
    
    guard let reservationSeq = reservationSeq else { return }
    
    dependency.rothemRepository.cancelRothemReservation(
      request: .init(
        reservationSeq: reservationSeq,
        userID: UserManager.shared.userID!
      )
    )
    .subscribe(with: self) { owner, _ in
      owner.dependency.coordinator.popViewController()
//      output.successCancelReservationSubject.onNext(())
    }
    .disposed(by: disposeBag)
  }
}
