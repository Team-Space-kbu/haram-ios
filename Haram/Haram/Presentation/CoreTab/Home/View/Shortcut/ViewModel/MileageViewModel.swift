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
  var errorMessage: Signal<HaramError> { get }
}

final class MileageViewModel {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  private let currentUserMileageInfoRelay  = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  private let currentAvilabilityPointRelay = PublishRelay<MileageTableHeaderViewModel>()
  private let errorMessageSubject          = PublishSubject<HaramError>()
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
    inquireMileageInfo()
  }
  
  private func inquireMileageInfo() {
    let tryInquireMileageInfo = intranetRepository.inquireMileageInfo()
    
    tryInquireMileageInfo
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { mileageDetail -> MileageTableViewCellModel in
            let mainText = mileageDetail.etc
            
            return MileageTableViewCellModel(
              mainText: mainText,
              subText: mileageDetail.changeDate,
              mileage: Int(String(mileageDetail.point.replacingOccurrences(of: ",", with: ""))) ?? 0,
              imageSource: owner.getMileageImageResource(which: mainText)
            )
          }
        )
        
        owner.currentAvilabilityPointRelay.accept(
          MileageTableHeaderViewModel(
            totalMileage: Int(String(response.mileagePayInfo.availabilityPoint.replacingOccurrences(of: ",", with: ""))) ?? 0
          )
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageSubject.onNext(error)
      })
      .disposed(by: disposeBag)
    
  }
}

extension MileageViewModel {
  private func getMileageImageResource(which mainText: String) -> ImageResource {
    if mainText.contains("카페") {
      return .cafeCostes
    } else if mainText.contains("헬스장") {
      return .gym
    } else if mainText.contains("매점") {
      return .store
    } else {
      return .cafeCostes
    }
  }
}

extension MileageViewModel: MileageViewModelType {
  var currentAvailabilityPoint: RxCocoa.Driver<MileageTableHeaderViewModel> {
    currentAvilabilityPointRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> {
    currentUserMileageInfoRelay.asDriver()
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageSubject.asSignal(onErrorSignalWith: .empty())
  }
}
