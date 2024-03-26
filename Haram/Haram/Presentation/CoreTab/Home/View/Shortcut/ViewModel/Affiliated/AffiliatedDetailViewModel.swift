//
//  AffiliatedDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol AffiliatedDetailViewModelType {
  var affiliatedDetailModel: Driver<AffiliatedDetailInfoViewModel> { get }
}

final class AffiliatedDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let affiliatedDetailModelRelay = BehaviorRelay<AffiliatedDetailInfoViewModel?>(value: nil)
  
  init() {
    affiliatedDetailModelRelay.accept(.init(
      title: "국시집",
      affiliatedLocationModel: .init(
        locationImageResource: .locationGray,
        locationContent: "서울 노원구 동일로 1343"),
      affiliatedIntroduceModel: .init(
        title: "소개",
        content: "쿠키 공방에서부터 출발한 '쿠방 플러스'는, 쿠키, 케익만들기 체험과 커피를 함께 즐길 수 있는 베이킹 카페입니다.\n\n저희는 '클래스'가 아닌 '체험' 서비스를 제공해요 @_@\n선생님들은 간단한 도구 사용법만 안내해 드리며, 모든 과정을 함께하지 않습니다.\n\n** 주차 공간 매우 협소합니다. 주말/공휴일에는 자리 부족할 수 있어요! **\n\n만드는 즐거움, 먹는 기쁨을 선물하기 위해 노력하는 쿠방플러스가 되겠습니다.\n감사합니다."),
      affiliatedBenefitModel: .init(
        title: "혜택",
        content: "상우와 함께 침대에서"),
      affiliatedMapViewModel: .init(
        title: "지도",
        coordinateX: Constants.currentLat, coordinateY: Constants.currentLng)
    ))
    
    affiliatedDetailModelRelay.accept(.init(
      title: "국시집",
      affiliatedLocationModel: .init(
        locationImageResource: .locationGray,
        locationContent: "서울 노원구 동일로 1343"),
      affiliatedIntroduceModel: .init(
        title: "소개",
        content: "쿠키 공방에서부터 출발한 '쿠방 플러스'는, 쿠키, 케익만들기 체험과 커피를 함께 즐길 수 있는 베이킹 카페입니다.\n\n저희는 '클래스'가 아닌 '체험' 서비스를 제공해요 @_@\n선생님들은 간단한 도구 사용법만 안내해 드리며, 모든 과정을 함께하지 않습니다.\n\n** 주차 공간 매우 협소합니다. 주말/공휴일에는 자리 부족할 수 있어요! **\n\n만드는 즐거움, 먹는 기쁨을 선물하기 위해 노력하는 쿠방플러스가 되겠습니다.\n감사합니다."),
      affiliatedBenefitModel: .init(
        title: "혜택",
        content: "상우와 함께 침대에서"),
      affiliatedMapViewModel: .init(
        title: "지도",
        coordinateX: Constants.currentLat, coordinateY: Constants.currentLng)
    ))
  }
  
}

extension AffiliatedDetailViewModel: AffiliatedDetailViewModelType {
  var affiliatedDetailModel: RxCocoa.Driver<AffiliatedDetailInfoViewModel> {
    affiliatedDetailModelRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
  }
}
