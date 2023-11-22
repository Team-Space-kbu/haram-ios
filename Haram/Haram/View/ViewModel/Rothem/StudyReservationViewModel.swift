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
  var reservationButtonTapped: AnyObserver<Void> { get }
  var whichReservationName: AnyObserver<String> { get }
  var whichReservationPhoneNumber: AnyObserver<String> { get }
  
  var studyRoomInfoViewModel: Driver<StudyRoomInfoViewModel> { get }
  var selectedDayCollectionViewCellModel: Driver<[SelectedDayCollectionViewCellModel]> { get }
  var selectedTimeCollectionViewCellModel: Driver<[SelectedTimeCollectionViewCellModel]> { get }
  var selectedPolicyModel: Driver<[TermsOfUseCheckViewModel]> { get }
  var isReservationButtonActivated: Driver<Bool> { get }
}

final class StudyReservationViewModel {
  
  private let disposeBag = DisposeBag()
  private let roomSeq: Int
  
  private var model: [CalendarResponse] = []
  private let timeTable = BehaviorRelay<[SelectedTimeCollectionViewCellModel]>(value: [])
  
  private let calendarSeqSubject = PublishSubject<Int>()
  private let selectTimeSeqSubject = PublishSubject<Int>()
  private let deSelectTimeSeqSubject = PublishSubject<Int>()
  private let reservationNameSubject = PublishSubject<String>()
  private let reservationPhoneNumerSubject = PublishSubject<String>()
  private let reservationButtonTappedSubject = PublishSubject<Void>()
  private let isReservationButtonActivatedSubject = PublishSubject<Bool>()
  
  private let studyRoomInfoViewModelRelay = PublishRelay<StudyRoomInfoViewModel>()
  private let selectedDayCollectionViewCellModelRelay = BehaviorRelay<[SelectedDayCollectionViewCellModel]>(value: [])
  private let policyModelRelay = BehaviorRelay<[TermsOfUseCheckViewModel]>(value: [])
  
  init(roomSeq: Int) {
    self.roomSeq = roomSeq
    inquireReservationInfo()
    getTimeInfoForReservation()
    saveTimeInfoForReservation()
    tryReserveStudyRoom()
    checkReservationInfoIsValid()
  }
  
  /// 예약하기위한 정보를 조회하는 함수, 맨 처음에만 호출
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
  
  /// 날짜 선택에 따른 시간정보를 가져오는 함수
  private func getTimeInfoForReservation() {
    calendarSeqSubject
      .distinctUntilChanged()
      .subscribe(with: self) { owner, calendarSeq in
        let findModel = owner.model.filter({ $0.calendarSeq == calendarSeq })
        
        /// 이용가능한 날짜만 선택가능
        guard findModel.first!.isAvailable else { return }
        
        let filterModel = findModel.flatMap { $0.times  }
        owner.timeTable.accept(filterModel.map { SelectedTimeCollectionViewCellModel(time: $0) })
      }
      .disposed(by: disposeBag)
  }
  
  /// 시간선택 혹은 미선택에 따른 시간정보를 저장하는 로직이 담김 함수
  private func saveTimeInfoForReservation() {
    
    selectTimeSeqSubject
      .subscribe(with: self) { owner, timeSeq in
        var timeModel = owner.timeTable.value
        
        /// 최대 선택 개수 2개
        guard timeModel.filter({ $0.isTimeSelected }).count < 2,
              !timeModel.filter({ $0.timeSeq == timeSeq }).first!.isReserved else { return }
        
        if timeModel.filter({ $0.isTimeSelected }).count == 1 {
          
          /// 선택한 timeSeq가 기존에 선택된 timeSeq와 연속적이라면
          if timeModel.filter({ $0.isTimeSelected }).map({ $0.timeSeq }).filter({ timeSeq == $0 + 1 || timeSeq == $0 - 1 }).count > 0 {
            let findModel = timeModel.filter { $0.timeSeq == timeSeq }.first!
            timeModel[timeModel.firstIndex(of: findModel)!].isTimeSelected = true
            owner.timeTable.accept(timeModel)
          }
          
          /// 연속적이지않은 timeSeq는 무시
          return
        }
        
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
  }
  
  /// 로뎀 스터디룸을 예약하는 함수
  private func tryReserveStudyRoom() {
    reservationButtonTappedSubject
      .withLatestFrom(
        Observable.combineLatest(
          reservationPhoneNumerSubject,
          calendarSeqSubject,
          policyModelRelay.map { $0.map { ReservationPolicyRequest(policySeq: $0.policySeq, policyAgreeYn: "Y") } },
          timeTable.map { $0.filter { $0.isTimeSelected }.map { TimeRequest(timeSeq: $0.timeSeq) } }
        ) { ($0, $1, $2, $3) }
      )
      .map { (phoneNum, calendarSeq, reservationPolicyRequests, timeRequests) in
        return ReserveStudyRoomRequest(
          userId: UserManager.shared.userID!,
          phoneNum: phoneNum,
          calendarSeq: calendarSeq,
          reservationPolicyRequests: reservationPolicyRequests,
          timeRequests: timeRequests
        )
      }
      .withUnretained(self)
      .flatMapLatest { owner, request in
        RothemService.shared.reserveStudyRoom(roomSeq: owner.roomSeq, request: request)
      }
      .subscribe(with: self) { owner, _ in
        print("예약에 성공했습니다.")
      }
      .disposed(by: disposeBag)
  }
  
  /// 예약정보가 올바르게 입력되었는지 확인하는 함수, 버튼 활성화 통제
  private func checkReservationInfoIsValid() {
    Observable.combineLatest(
      reservationPhoneNumerSubject,
      policyModelRelay,
      timeTable.map { $0.filter { $0.isTimeSelected } }
    ) { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty }
      .subscribe(with: self) { owner, isActivated in
        owner.isReservationButtonActivatedSubject.onNext(isActivated)
      }
      .disposed(by: disposeBag)
  }
}

extension StudyReservationViewModel: StudyReservationViewModelType {
  var reservationButtonTapped: RxSwift.AnyObserver<Void> {
    reservationButtonTappedSubject.asObserver()
  }
  
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
  
  var whichReservationName: AnyObserver<String> {
    reservationNameSubject.asObserver()
  }
  
  var whichReservationPhoneNumber: AnyObserver<String> {
    reservationPhoneNumerSubject.asObserver()
  }
  
  var isReservationButtonActivated: Driver<Bool> {
    isReservationButtonActivatedSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
