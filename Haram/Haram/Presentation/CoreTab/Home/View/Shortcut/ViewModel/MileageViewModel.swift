//
//  MileageViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/20.
//

import Foundation

import RxSwift
import RxCocoa

protocol MileageViewModelType {
  
  func inquireMileageInfo()
  
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> { get }
  var currentAvailabilityPoint: Driver<MileageTableHeaderViewModel> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class MileageViewModel {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  private let currentUserMileageInfoRelay  = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  private let currentAvilabilityPointRelay = PublishRelay<MileageTableHeaderViewModel>()
  private let errorMessageRelay          = BehaviorRelay<HaramError?>(value: nil)
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
  }
}

extension MileageViewModel {
  private func getMileageImageResource(which type: MileageDetailType) -> ImageResource {
    
    switch type {
    case .cafe:
      return .cafeCostes
    case .gym:
      return .gym
    case .mart:
      return .store
    case .bookStore:
      return .bookStore
    case .copyRoom:
      return .copyRoom
    case .student:
      return .student
    case .etc:
      return .etc
    }
  }
}

extension MileageViewModel: MileageViewModelType {
  
  func inquireMileageInfo() {
    let tryInquireMileageInfo = intranetRepository.inquireMileageInfo()
    
    tryInquireMileageInfo
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { mileageDetail -> MileageTableViewCellModel in
            let mainText = mileageDetail.etc
            
            return MileageTableViewCellModel(
              mainText: mainText,
              date: DateformatterFactory.dateForISO8601UTC.date(from: mileageDetail.changeDate) ?? Date(),
              mileage: mileageDetail.point,
              imageSource: owner.getMileageImageResource(which: mileageDetail.type)
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
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
    
  }
  
  var currentAvailabilityPoint: RxCocoa.Driver<MileageTableHeaderViewModel> {
    currentAvilabilityPointRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> {
    currentUserMileageInfoRelay.asDriver()
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
}
