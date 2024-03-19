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
  var errorMessage: Signal<HaramError> { get }
}

final class RothemRoomListViewModel {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository
  
  private let studyReservationListRelay = PublishRelay<[StudyListCollectionViewCellModel]>()
  private let rothemMainNoticeRelay     = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  private let isReservationSubject      = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay         = BehaviorRelay<HaramError?>(value: nil)

  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
  
}


extension RothemRoomListViewModel: RothemRoomListViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  
  func inquireRothemRoomList() {
    rothemRepository.inquireRothemHomeInfo(userID: UserManager.shared.userID!)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.studyReservationListRelay.accept(response.roomList.enumerated().map { index, room in
          return StudyListCollectionViewCellModel(rothemRoom: room, isLast: index == response.roomList.count - 1)
        })
        owner.rothemMainNoticeRelay.accept(response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) })
        owner.isReservationSubject.onNext(response.isReserved == 1)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var currentRothemMainNotice: RxCocoa.Driver<StudyListHeaderViewModel?> {
    rothemMainNoticeRelay
      .asDriver(onErrorJustReturn: nil)
  }
  
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> {
    studyReservationListRelay
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isReservation: Driver<StudyListCollectionHeaderViewType> {
    isReservationSubject
      .map { $0 ? .reservation : .noReservation }
      .asDriver(onErrorDriveWith: .empty())
  }

}
