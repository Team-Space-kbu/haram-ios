//
//  MileageViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/20.
//

import RxSwift
import RxCocoa

protocol MileageViewModelType {
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> { get }
  var currentAvailabilityPoint: Driver<MileageTableHeaderViewModel> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class MileageViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentUserMileageInfoRelay  = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  private let currentAvilabilityPointRelay = PublishRelay<MileageTableHeaderViewModel>()
  private let isLoadingSubject             = PublishSubject<Bool>()
  private let errorMessageSubject          = PublishSubject<HaramError>()
  
  init() {
    inquireMileageInfo()
  }
  
  private func inquireMileageInfo() {
    let tryInquireMileageInfo = IntranetService.shared.inquireMileageInfo()
    
    tryInquireMileageInfo
      .do(onSuccess: { [weak self] _ in self?.isLoadingSubject.onNext(true) })
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { MileageTableViewCellModel(
            mainText: $0.etc,
            subText: $0.changeDate,
            mileage: Int(String($0.point.replacingOccurrences(of: ",", with: ""))) ?? 0)
          }
        )
        
        owner.currentAvilabilityPointRelay.accept(
          MileageTableHeaderViewModel(totalMileage: Int(String(response.mileagePayInfo.availabilityPoint.replacingOccurrences(of: ",", with: ""))) ?? 0)
        )
        
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageSubject.onNext(error)
      })
      .disposed(by: disposeBag)
    
  }
}

extension MileageViewModel: MileageViewModelType {
  var currentAvailabilityPoint: RxCocoa.Driver<MileageTableHeaderViewModel> {
    currentAvilabilityPointRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> {
    currentUserMileageInfoRelay.asDriver()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageSubject.asSignal(onErrorSignalWith: .empty())
  }
}
