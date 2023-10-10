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
  
  var isLoading: Driver<Bool> { get }
}

final class StudyListViewModel {
  
  private let disposeBag = DisposeBag()
  
  
  private let studyReservationListRelay = BehaviorRelay<[StudyListCollectionViewCellModel]>(value: [])
  private let studyReservationHeaderRelay = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    studyReservationListRelay.accept([
      .init(title: "개인학습실", description: "그룹학습실은 한국성서대학교 학생이라면 누구나 대관해서 공부나 팀프로젝트, 개인프로젝트, 과제 등등 학습을 위해서라면 언제든 대관을 해드립니다!", imageURL: URL(string: "http://ctl.bible.ac.kr/attachment/view/20544/KakaoTalk_20210531_142417965.jpg?ts=0")),
      .init(title: "4인 학습실", description: "그룹학습실은 한국성서대학교 학생이라면 누구나 대관해서 공부나 팀프로젝트, 개인프로젝트, 과제 등등 학습을 위해서라면 언제든 대관을 해드립니다!", imageURL: URL(string: "http://ctl.bible.ac.kr/attachment/view/20549/KakaoTalk_20210531_142417965_01.jpg?ts=0")),
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
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}
