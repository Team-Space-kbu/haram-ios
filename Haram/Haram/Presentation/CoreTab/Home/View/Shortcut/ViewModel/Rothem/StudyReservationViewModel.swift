//
//  StudyReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/19/23.
//

import Foundation

import RxSwift
import RxCocoa

protocol StudyReservationViewModelType {
  
  func checkCheckBox(policySeq: Int, isChecked: Bool)
  
  var whichCalendarSeq: AnyObserver<Int> { get }
  var selectTimeSeq: AnyObserver<Int> { get }
  var deSelectTimeSeq: AnyObserver<Int> { get }
  var reservationButtonTapped: AnyObserver<Void> { get }
  var whichReservationName: AnyObserver<String> { get }
  var whichReservationPhoneNumber: AnyObserver<String> { get }
  var errorMessage: Signal<HaramError> { get }
  
  var studyRoomInfoViewModel: Driver<StudyRoomInfoViewModel> { get }
  var selectedDayCollectionViewCellModel: Driver<[SelectedDayCollectionViewCellModel]> { get }
  var selectedTimeCollectionViewCellModel: Driver<[SelectedTimeCollectionViewCellModel]> { get }
  var selectedPolicyModel: Driver<[TermsOfUseCheckViewModel]> { get }
  var isReservationButtonActivated: Driver<Bool> { get }
  var successRothemReservation: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
}

final class StudyReservationViewModel {
  
  private let rothemRepository: RothemRepository
  private let disposeBag = DisposeBag()
  private let roomSeq: Int
  
  private var model: [CalendarResponse] = []
  private let timeTable = BehaviorRelay<[SelectedTimeCollectionViewCellModel]>(value: [])
  
  private let calendarSeqSubject                      = PublishSubject<Int>()
  private let selectTimeSeqSubject                    = PublishSubject<Int>()
  private let deSelectTimeSeqSubject                  = PublishSubject<Int>()
  private let reservationNameSubject                  = PublishSubject<String>()
  private let reservationPhoneNumerSubject            = PublishSubject<String>()
  private let reservationButtonTappedSubject          = PublishSubject<Void>()
  private let successRothemReservationSubject         = PublishSubject<Void>()
  private let isLoadingSubject                        = PublishSubject<Bool>()
  
  private let studyRoomInfoViewModelRelay             = PublishRelay<StudyRoomInfoViewModel>()
  private let selectedDayCollectionViewCellModelRelay = BehaviorRelay<[SelectedDayCollectionViewCellModel]>(value: [])
  private let policyModelRelay                        = BehaviorRelay<[TermsOfUseCheckViewModel]>(value: [])
  private let errorMessageRelay                       = PublishRelay<HaramError>()
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl(), roomSeq: Int) {
    self.rothemRepository = rothemRepository
    self.roomSeq = roomSeq
    inquireReservationInfo()
    getTimeInfoForReservation()
    saveTimeInfoForReservation()
    tryReserveStudyRoom()
  }
  
  /// 예약하기위한 정보를 조회하는 함수, 맨 처음에만 호출
  private func inquireReservationInfo() {
    let inquireReservationInfo = rothemRepository.checkTimeAvailableForRothemReservation(roomSeq: roomSeq)
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    inquireReservationInfo
      .asObservable()
      .take(1)
      .subscribe(with: self) { owner, response in
        owner.studyRoomInfoViewModelRelay.accept(StudyRoomInfoViewModel(roomResponse: response.roomResponse))
        owner.selectedDayCollectionViewCellModelRelay.accept(response.calendarResponses.map { SelectedDayCollectionViewCellModel(calendarResponse: $0) })
        owner.model = response.calendarResponses
        owner.policyModelRelay.accept(response.policyResponses.sorted(by: { $0.policySeq > $1.policySeq }).map { TermsOfUseCheckViewModel(response: $0) })
        
        if let model = response.calendarResponses.filter({ $0.isAvailable }).first {
          owner.calendarSeqSubject.onNext(model.calendarSeq)
        }
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
  
  /// 날짜 선택에 따른 시간정보를 가져오는 함수
  private func getTimeInfoForReservation() {
    calendarSeqSubject
      .distinctUntilChanged()
      .subscribe(with: self) { owner, calendarSeq in
        let findModel = owner.model.filter({ $0.calendarSeq == calendarSeq }).first!
        
        /// 이용가능한 날짜만 선택가능
        guard findModel.isAvailable,
              let filterModel = findModel.times else { return }
        
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
              !timeModel.filter({ $0.timeSeq == timeSeq }).first!.isReserved else {
          owner.errorMessageRelay.accept(.maxReservationCount)
          return
        }
        
        if timeModel.filter({ $0.isTimeSelected }).count == 1 {
          
          /// 선택한 timeSeq가 기존에 선택된 timeSeq와 연속적이라면
          if timeModel.filter({ $0.isTimeSelected }).map({ $0.timeSeq }).filter({ timeSeq == $0 + 1 || timeSeq == $0 - 1 }).count > 0 {
            let findModel = timeModel.filter { $0.timeSeq == timeSeq }.first!
            timeModel[timeModel.firstIndex(of: findModel)!].isTimeSelected = true
            owner.timeTable.accept(timeModel)
          } else {
            /// 연속적이지않은 timeSeq는 무시
            owner.errorMessageRelay.accept(.nonConsecutiveReservations)
            return
          }
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
          reservationNameSubject,
          reservationPhoneNumerSubject,
          calendarSeqSubject,
          policyModelRelay.map { $0.map { ReservationPolicyRequest(policySeq: $0.policySeq, policyAgreeYn: "Y") } },
          timeTable.map { $0.filter { $0.isTimeSelected }.map { TimeRequest(timeSeq: $0.timeSeq) } }
        ) { ($0, $1, $2, $3, $4) }
      )
      .map { (userName, phoneNum, calendarSeq, reservationPolicyRequests, timeRequests) in
        return ReserveStudyRoomRequest(
          userName: userName,
          phoneNum: phoneNum,
          calendarSeq: calendarSeq,
          reservationPolicyRequests: reservationPolicyRequests,
          timeRequests: timeRequests
        )
      }
      .withUnretained(self)
      .flatMapLatest { owner, request in
        owner.rothemRepository.reserveStudyRoom(roomSeq: owner.roomSeq, request: request)
      }
      .subscribe(with: self, onNext: { owner, _ in
        owner.successRothemReservationSubject.onNext(())
      }, onError: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
    // 전화번호 형식: XXX-XXXX-XXXX 또는 XXXXXXXXXX
    let phoneRegex = #"^\d{3}-?\d{4}-?\d{4}$"#
    
    let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return phonePredicate.evaluate(with: phoneNumber)
  }
  
}

extension StudyReservationViewModel: StudyReservationViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  func checkCheckBox(policySeq: Int, isChecked: Bool) {
    var policyModel = policyModelRelay.value
    policyModelRelay.accept(
      policyModel.map { policy in
        var policy = policy
        // 특정 번호에 해당하는 정책을 찾았다면
        if policy.policySeq == policySeq {
          policy.isChecked = isChecked
        }
        return policy
      }
    )
  }
  
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
    policyModelRelay.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: [])
  }
  
  var whichReservationName: AnyObserver<String> {
    reservationNameSubject.asObserver()
  }
  
  var whichReservationPhoneNumber: AnyObserver<String> {
    reservationPhoneNumerSubject.asObserver()
  }
  
  var isReservationButtonActivated: Driver<Bool> {
    Observable.combineLatest(
      reservationPhoneNumerSubject,
      policyModelRelay,
      timeTable.map { $0.filter { $0.isTimeSelected } },
      reservationNameSubject
    ) { [weak self] in
      guard let self = self else { return false }
      return self.isValidPhoneNumber($0) && $1.filter { !$0.isChecked }.count == 0 && !$2.isEmpty && !$3.isEmpty
    }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)
  }
  
  var successRothemReservation: Signal<Void> {
    successRothemReservationSubject.asSignal(onErrorSignalWith: .empty())
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
