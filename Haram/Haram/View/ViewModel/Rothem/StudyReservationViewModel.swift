//
//  StudyReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/19/23.
//

import RxSwift
import RxCocoa

protocol StudyReservationViewModelType {
  var whichCalendarSeq: AnyObserver<Int> { get }
  var whichTimeSeq: AnyObserver<Int> { get }
  
  var studyRoomInfoViewModel: Driver<StudyRoomInfoViewModel> { get }
  var selectedDayCollectionViewCellModel: Driver<[SelectedDayCollectionViewCellModel]> { get }
  var selectedTimeCollectionViewCellModel: Driver<[SelectedTimeCollectionViewCellModel]> { get }
}

final class StudyReservationViewModel {
  
  private let disposeBag = DisposeBag()
  private let roomSeq: Int
  
  private var model: [CalendarResponse] = []
  
  private let timeTable = PublishRelay<[SelectedTimeCollectionViewCellModel]>()
  
  private let calendarSeqSubject = PublishSubject<Int>()
  private let timeSeqSubject = PublishSubject<Int>()
  private let studyRoomInfoViewModelRelay = PublishRelay<StudyRoomInfoViewModel>()
  private let selectedDayCollectionViewCellModelRelay = BehaviorRelay<[SelectedDayCollectionViewCellModel]>(value: [])
  
  init(roomSeq: Int) {
    self.roomSeq = roomSeq
    inquireReservationInfo()
    getTimeInfoForReservation()
  }
  
  private func inquireReservationInfo() {
    let inquireReservationInfo = RothemService.shared.checkTimeAvailableForRothemReservation(roomSeq: roomSeq)
    
    inquireReservationInfo
      .subscribe(with: self) { owner, response in
        owner.studyRoomInfoViewModelRelay.accept(StudyRoomInfoViewModel(roomResponse: response.roomResponse))
        owner.selectedDayCollectionViewCellModelRelay.accept(response.calendarResponses.map { SelectedDayCollectionViewCellModel(calendarResponse: $0) })
        owner.model = response.calendarResponses
        guard let model = response.calendarResponses.filter({ $0.isAvailable }).first else { return }
        owner.calendarSeqSubject.onNext(model.calendarSeq)
      }
      .disposed(by: disposeBag)
  }
  
  private func getTimeInfoForReservation() {
    calendarSeqSubject
      .subscribe(with: self) { owner, calendarSeq in
        let filterModel = owner.model.filter { $0.calendarSeq == calendarSeq }.flatMap { $0.times  }
        owner.timeTable.accept(filterModel.map { SelectedTimeCollectionViewCellModel(time: $0) })
      }
      .disposed(by: disposeBag)
  }
}

extension StudyReservationViewModel: StudyReservationViewModelType {
  var whichCalendarSeq: RxSwift.AnyObserver<Int> {
    calendarSeqSubject.asObserver()
  }
  
  var selectedDayCollectionViewCellModel: RxCocoa.Driver<[SelectedDayCollectionViewCellModel]> {
    selectedDayCollectionViewCellModelRelay.asDriver()
  }
  
  var studyRoomInfoViewModel: Driver<StudyRoomInfoViewModel> {
    studyRoomInfoViewModelRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var selectedTimeCollectionViewCellModel: Driver<[SelectedTimeCollectionViewCellModel]> {
    timeTable.asDriver(onErrorDriveWith: .empty())
  }
  
  var whichTimeSeq: AnyObserver<Int> {
    timeSeqSubject.asObserver()
  }
}
