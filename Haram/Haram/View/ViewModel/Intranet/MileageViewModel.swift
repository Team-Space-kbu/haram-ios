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
}

final class MileageViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentUserMileageInfoRelay = BehaviorRelay<[MileageTableViewCellModel]>(value: [])
  
  init() {
    inquireMileageInfo()
  }
  
  private func inquireMileageInfo() {
    let tryInquireMileageInfo = IntranetService.shared.inquireMileageInfo()
    
    tryInquireMileageInfo
      .subscribe(with: self) { owner, response in
        owner.currentUserMileageInfoRelay.accept(
          response.mileageDetails.map { MileageTableViewCellModel(
            mainText: $0.etc,
            subText: "한국성서대학교",
            mileage: Int(String($0.point)) ?? 0)
          }
        )
      }
      .disposed(by: disposeBag)
  }
}

extension MileageViewModel: MileageViewModelType {
  var currentUserMileageInfo: Driver<[MileageTableViewCellModel]> {
    currentUserMileageInfoRelay.asDriver()
  }
}
