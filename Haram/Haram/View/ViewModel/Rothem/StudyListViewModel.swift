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
  
  var requestStudyList: AnyObserver<Void> { get }
  
  var currentStudyReservationList: Driver<[StudyListCollectionViewCellModel]> { get }
  var currentRothemMainNotice: Driver<StudyListHeaderViewModel?> { get }
  var isLoading: Driver<Bool> { get }
  var isReservation: Driver<StudyListCollectionHeaderViewType> { get }
}

final class StudyListViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let requestStudyListSubject   = PublishSubject<Void>()
  private let studyReservationListRelay = BehaviorRelay<[StudyListCollectionViewCellModel]>(value: [])
  private let rothemMainNoticeRelay     = BehaviorRelay<StudyListHeaderViewModel?>(value: nil)
  private let isLoadingSubject          = PublishSubject<Bool>()
  private let isReservationSubject      = BehaviorSubject<Bool>(value: false)
  
  init() {
    inquireRothemHomeInfo()
    
  }
}

extension StudyListViewModel {
  
  private func inquireRothemHomeInfo() {
    let inquireRothemHomeInfo = requestStudyListSubject
      .flatMapLatest { RothemService.shared.inquireRothemHomeInfo(userID: UserManager.shared.userID!) }
    
    inquireRothemHomeInfo
      .do(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .subscribe(with: self) { owner, response in
        owner.studyReservationListRelay.accept(response.roomList.map { StudyListCollectionViewCellModel(rothemRoom: $0) })
        owner.rothemMainNoticeRelay.accept(response.noticeList.first.map { StudyListHeaderViewModel(rothemNotice: $0) })
        owner.isReservationSubject.onNext(response.isReserved == 1)
        
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
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
  
  var isReservation: Driver<StudyListCollectionHeaderViewType> {
    isReservationSubject
      .map { $0 ? .reservation : .noReservation }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var requestStudyList: AnyObserver<Void> {
    requestStudyListSubject.asObserver()
  }
}
