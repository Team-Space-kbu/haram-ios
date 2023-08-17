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

final class MileageViewModel: MileageViewModelType {
  
  let currentUserMileageInfo: Driver<[MileageTableViewCellModel]>
  
  init() {
    let currentMileageRelay = BehaviorRelay<[MileageTableViewCellModel]>(value: [
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "성적 최우수상", subText: "한국성서대학교", mileage: 200000),
      MileageTableViewCellModel(mainText: "도서 구매", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "매점", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "도서 구매", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "도서 구매", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "매점", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "매점", subText: "한국성서대학교", mileage: -2000),
      MileageTableViewCellModel(mainText: "카페 코스테스", subText: "한국성서대학교", mileage: -2000),
    ])
    currentUserMileageInfo = currentMileageRelay.asDriver()
    
    
  }
}
