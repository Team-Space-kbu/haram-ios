//
//  StudyListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import Foundation

import RxSwift
import RxCocoa

protocol StudyListViewModelType {
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> { get }
  var currentStudyReservationHeaderModel: Driver<StudyListHeaderViewModel?> { get }
}

final class StudyListViewModel {
  
  private let disposeBag = DisposeBag()
  
  
  private let studyReservationListRelay = BehaviorRelay<[StudyListCollectionViewCellModel]>(value: [])
  private let studyReservationHeaderRelay = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  
  init() {
    studyReservationListRelay.accept([
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
      .init(title: "최고의 IOS개발자가 되기위한 스터디", description: "IOS와 관련된 공부를 열심히 하면서 실력을 향상해 나가기위한 스터디입니다.", imageURL: URL(string: "")),
    ])
    
    studyReservationHeaderRelay.accept(
      .init(thumbnailImageURL: URL(string: ""), title: "안녕하세요 한국성서대학교 로뎀나무입니다.", description: "스터디룸 예약을 통해서 원하는 방에 편리하게 예약해보세요 !!")
    )
  }
}

extension StudyListViewModel {
  private func inquireAllRoomInfo() {
    let inquireAllRoomInfo = RothemService.shared.inquireAllRoomInfo()
    
    let inquireAllRoomInfoToResponse = inquireAllRoomInfo
      .compactMap { result -> [InquireAllRoomInfoResponse]? in
      guard case let .success(response) = result else { return nil }
      return response
    }
    
    inquireAllRoomInfoToResponse
    
  }
}

extension StudyListViewModel: StudyListViewModelType {
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> {
    studyReservationListRelay.asDriver()
  }
  
  var currentStudyReservationHeaderModel: Driver<StudyListHeaderViewModel?> {
    studyReservationHeaderRelay.asDriver(onErrorJustReturn: nil)
  }
}
