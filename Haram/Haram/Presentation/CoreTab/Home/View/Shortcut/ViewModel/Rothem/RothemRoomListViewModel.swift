//
//  StudyListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import Foundation

import RxSwift
import RxCocoa

protocol RothemRoomListViewModelType {
  
  func inquireRothemRoomList()
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> { get }
  var currentRothemMainNotice: Driver<StudyListHeaderViewModel?> { get }
  var isReservation: Driver<StudyListCollectionHeaderViewType> { get }
}

final class RothemRoomListViewModel {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository
  
  private let studyReservationListRelay = BehaviorRelay<[StudyListCollectionViewCellModel]>(value: [])
  private let rothemMainNoticeRelay     = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  private let isReservationSubject      = BehaviorSubject<Bool>(value: false)

  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
  
}


extension RothemRoomListViewModel: RothemRoomListViewModelType {
  
  func inquireRothemRoomList() {
    rothemRepository.inquireRothemHomeInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self) { owner, response in
        owner.studyReservationListRelay.accept(response.roomList.enumerated().map { index, room in
          return StudyListCollectionViewCellModel(rothemRoom: room, isLast: index == response.roomList.count - 1)
        })
        owner.rothemMainNoticeRelay.accept(response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) })
        owner.isReservationSubject.onNext(response.isReserved == 1)
      }
      .disposed(by: disposeBag)
  }
  
  var currentRothemMainNotice: RxCocoa.Driver<StudyListHeaderViewModel?> {
    rothemMainNoticeRelay
      .asDriver(onErrorJustReturn: nil)
  }
  
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> {
    studyReservationListRelay.asDriver()
  }
  
  var isReservation: Driver<StudyListCollectionHeaderViewType> {
    isReservationSubject
      .map { $0 ? .reservation : .noReservation }
      .asDriver(onErrorDriveWith: .empty())
  }

}
