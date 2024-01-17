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
  private let intranetRepository: IntranetRepository
  
  private let currentUserMileageInfoRelay  = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  private let currentAvilabilityPointRelay = PublishRelay<MileageTableHeaderViewModel>()
  private let isLoadingSubject             = PublishSubject<Bool>()
  private let errorMessageSubject          = PublishSubject<HaramError>()
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
    inquireMileageInfo()
  }
  
  private func inquireMileageInfo() {
    let tryInquireMileageInfo = intranetRepository.inquireMileageInfo()
    
    tryInquireMileageInfo
      .do(onSuccess: { [weak self] _ in self?.isLoadingSubject.onNext(true) })
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { mileageDetail -> MileageTableViewCellModel in
            let mainText = mileageDetail.etc
            let imageSource: ImageResource
            if mainText.contains("카페") {
              imageSource = .cafeCostes
            } else if mainText.contains("헬스장") {
              imageSource = .gym
            } else if mainText.contains("매점") {
              imageSource = .store
            } else {
              imageSource = .cafeCostes
            }
            
            return MileageTableViewCellModel(
              mainText: mainText,
              subText: mileageDetail.changeDate,
              mileage: Int(String(mileageDetail.point.replacingOccurrences(of: ",", with: ""))) ?? 0,
              imageSource: imageSource
            )
          }
        )
        
        owner.currentAvilabilityPointRelay.accept(
          MileageTableHeaderViewModel(
            totalMileage: Int(String(response.mileagePayInfo.availabilityPoint.replacingOccurrences(of: ",", with: ""))) ?? 0
          )
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
