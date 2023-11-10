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
}

final class MileageViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentUserMileageInfoRelay = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  private let currentAvilabilityPointRelay = PublishRelay<MileageTableHeaderViewModel>()
  
  init() {
    inquireMileageInfo()
  }
  
  private func inquireMileageInfo() {
    let tryInquireMileageInfo = IntranetService.shared.inquireMileageInfo()
    
    tryInquireMileageInfo
      .subscribe(with: self) { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { MileageTableViewCellModel(
            mainText: $0.etc.replacingOccurrences(of: "성서대.", with: ""),
            subText: $0.changeDate,
            mileage: Int(String($0.point)) ?? 0)
          }
        )
        
        owner.currentAvilabilityPointRelay.accept(
          MileageTableHeaderViewModel(totalMileage: Int(String(response.mileagePayInfo.availabilityPoint)) ?? 0)
        )
      }
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
}
