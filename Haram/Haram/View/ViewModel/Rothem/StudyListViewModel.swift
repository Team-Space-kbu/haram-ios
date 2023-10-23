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
  var currentRothemMainNotice: Driver<StudyListHeaderViewModel?> { get }
  
  var isLoading: Driver<Bool> { get }
  var isReservation: Driver<Bool> { get }
}

final class StudyListViewModel {
  
  private let disposeBag = DisposeBag()
  
  
  private let studyReservationListRelay = BehaviorRelay<[StudyListCollectionViewCellModel]>(value: [])
  private let rothemMainNoticeRelay = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  
  private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
  private let isReservationSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    inquireRothemHomeInfo()
    
  }
}

extension StudyListViewModel {
  
  private func inquireRothemHomeInfo() {
    let inquireRothemHomeInfo = RothemService.shared.inquireRothemHomeInfo(userID: UserManager.shared.userID!)
    
    let successInquireRothemHomeInfo = inquireRothemHomeInfo
      .compactMap { result -> InquireRothemHomeInfoResponse? in
        guard case let .success(response) = result else { return nil }
        return response
      }
    
    successInquireRothemHomeInfo
      .subscribe(with: self) { owner, response in
        owner.studyReservationListRelay.accept(response.roomList.map { StudyListCollectionViewCellModel(rothemRoom: $0) })
        owner.rothemMainNoticeRelay.accept(response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) })
      }
      .disposed(by: disposeBag)
    //    let inquireAllRothemNotice = RothemService.shared.inquireAllRothemNotice()
    //
    //    let inquireAllRothemNoticeToResponse = inquireAllRothemNotice
    //      .compactMap { result -> InquireAllRothemNoticeResponse? in
    //      guard case let .success(response) = result else { return nil }
    //        return response.first
    //    }
    //
    //    inquireAllRothemNoticeToResponse
    //      .map { StudyListHeaderViewModel(response: $0) }
    //      .subscribe(with: self) { owner, rothemMainNotice in
    //        owner.rothemMainNoticeRelay.accept(rothemMainNotice)
    //      }
    //      .disposed(by: disposeBag)
  }
}

extension StudyListViewModel: StudyListViewModelType {
  var currentRothemMainNotice: RxCocoa.Driver<StudyListHeaderViewModel?> {
    rothemMainNoticeRelay
      .asDriver(onErrorJustReturn: nil)
  }
  
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> {
    studyReservationListRelay.asDriver()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var isReservation: Driver<Bool> {
    isReservationSubject.asDriver(onErrorJustReturn: false)
  }
}
