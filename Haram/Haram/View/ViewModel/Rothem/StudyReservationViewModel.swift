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
  var selectTimeSeq: AnyObserver<Int> { get }
  var deSelectTimeSeq: AnyObserver<Int> { get }
  
  var studyRoomInfoViewModel: Driver<StudyRoomInfoViewModel> { get }
  var selectedDayCollectionViewCellModel: Driver<[SelectedDayCollectionViewCellModel]> { get }
  var selectedTimeCollectionViewCellModel: Driver<[SelectedTimeCollectionViewCellModel]> { get }
  var selectedPolicyModel: Driver<[TermsOfUseCheckViewModel]> { get }
}

final class StudyReservationViewModel {
  
  private let disposeBag = DisposeBag()
  private let roomSeq: Int
  
  private var model: [CalendarResponse] = []
  
  private let timeTable = BehaviorRelay<[SelectedTimeCollectionViewCellModel]>(value: [])
  
  private var timeSeqList = BehaviorRelay<Set<Int>>(value: [])
  
  private let calendarSeqSubject = PublishSubject<Int>()
  private let selectTimeSeqSubject = PublishSubject<Int>()
  private let deSelectTimeSeqSubject = PublishSubject<Int>()
  private let studyRoomInfoViewModelRelay = PublishRelay<StudyRoomInfoViewModel>()
  private let selectedDayCollectionViewCellModelRelay = BehaviorRelay<[SelectedDayCollectionViewCellModel]>(value: [])
  private let policyModelRelay = BehaviorRelay<[TermsOfUseCheckViewModel]>(value: [])
  
  init(roomSeq: Int) {
    self.roomSeq = roomSeq
    inquireReservationInfo()
    getTimeInfoForReservation()
    saveTimeInfoForReservation()
    
    timeTable
      .subscribe(onNext: { model in
        print("모델로 \(model)")
      })
      .disposed(by: disposeBag)
  }
  
  private func inquireReservationInfo() {
    let inquireReservationInfo = RothemService.shared.checkTimeAvailableForRothemReservation(roomSeq: roomSeq)
    
    inquireReservationInfo
      .asObservable()
      .take(1)
      .subscribe(with: self) { owner, response in
        owner.studyRoomInfoViewModelRelay.accept(StudyRoomInfoViewModel(roomResponse: response.roomResponse))
        owner.selectedDayCollectionViewCellModelRelay.accept(response.calendarResponses.map { SelectedDayCollectionViewCellModel(calendarResponse: $0) })
        owner.model = response.calendarResponses
        owner.policyModelRelay.accept(response.policyResponses.map { TermsOfUseCheckViewModel(response: $0) })
        
        guard let model = response.calendarResponses.filter({ $0.isAvailable }).first else { return }
        owner.calendarSeqSubject.onNext(model.calendarSeq)
      }
      .disposed(by: disposeBag)
  }
  
  private func getTimeInfoForReservation() {
    calendarSeqSubject
      .distinctUntilChanged()
      .subscribe(with: self) { owner, calendarSeq in
        let filterModel = owner.model.filter { $0.calendarSeq == calendarSeq }.flatMap { $0.times  }
        owner.timeTable.accept(filterModel.map { SelectedTimeCollectionViewCellModel(time: $0) })
      }
      .disposed(by: disposeBag)
  }
  
  /// 시간선택에 따른 시간정보를 저장하는 로직이 담김 함수
  private func saveTimeInfoForReservation() {
    
    selectTimeSeqSubject
      .subscribe(with: self) { owner, timeSeq in
        var timeModel = owner.timeTable.value
        let findModel = timeModel.filter { $0.timeSeq == timeSeq }.first!
        timeModel[timeModel.firstIndex(of: findModel)!].isTimeSelected = true
        owner.timeTable.accept(timeModel)
      }
      .disposed(by: disposeBag)
    
    deSelectTimeSeqSubject
      .subscribe(with: self) { owner, timeSeq in
        var timeModel = owner.timeTable.value
        let findModel = timeModel.filter { $0.timeSeq == timeSeq }.first!
        timeModel[timeModel.firstIndex(of: findModel)!].isTimeSelected = false
        owner.timeTable.accept(timeModel)
      }
      .disposed(by: disposeBag)
    
//    timeSeqSubject
//      .subscribe(with: self) { owner, timeSeq in
//        var timeTable = owner.timeTable.value
        
        
//        var timeSeqList = owner.timeSeqList.value
//        
//        /// 타임번호 리스트 개수 제한 2개
//        if timeSeqList.count >= 2 {
////          _ = timeSeqList.remove
//          owner.timeSeqList.accept(timeSeqList)
//          
//        } else {
//          timeSeqList.insert(timeSeq)
//          owner.timeSeqList.accept(timeSeqList)
//        }
//      }
//      .disposed(by: disposeBag)
  
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
    timeTable.asDriver()
  }
  
  var selectTimeSeq: AnyObserver<Int> {
    selectTimeSeqSubject.asObserver()
  }
  
  var deSelectTimeSeq: AnyObserver<Int> {
    deSelectTimeSeqSubject.asObserver()
  }
  
  var selectedPolicyModel: Driver<[TermsOfUseCheckViewModel]> {
    policyModelRelay.asDriver()
  }
}
