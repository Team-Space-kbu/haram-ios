//
//  RothemRoomReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/19/23.
//

import Foundation

import RxSwift
import RxCocoa

final class RothemRoomReservationViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let roomSeq: Int
  }
  
  struct Dependency {
    let rothemRepository: RothemRepository
    let coordinator: RothemRoomReservationCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didEditReservationName: Observable<String>
    let didEditReservationPhoneNumber: Observable<String>
    let didTapReservationDayCell: Observable<IndexPath>
    let didTapReservationTimeCell: Observable<IndexPath>
    let didTapTermsOfUseCell: Observable<IndexPath>
    let didTapReservationButton: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    let studyRoomInfoViewModel             = PublishRelay<StudyRoomInfoViewModel>()
    let selectedDayCollectionViewCellModel = BehaviorRelay<[SelectedDayCollectionViewCellModel]>(value: [])
    let policyModel                        = BehaviorRelay<[TermsOfUseTableViewCellModel]>(value: [])
    let errorMessage                       = PublishRelay<HaramError>()
    let isLoading                          = PublishSubject<Bool>()
    let amModel = BehaviorRelay<[SelectedTimeCollectionViewCellModel]>(value: [])
    let pmModel = BehaviorRelay<[SelectedTimeCollectionViewCellModel]>(value: [])
    let isEnabledReservationButton = BehaviorRelay<Bool>(value: false)
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.combineLatest(
      input.didEditReservationPhoneNumber,
      output.policyModel,
      output.amModel.map { $0.filter(\.isTimeSelected) },
      output.pmModel.map { $0.filter(\.isTimeSelected) },
      input.didEditReservationName
    ) { [weak self] in
      guard let self = self else { return false }
      return self.isValidPhoneNumber($0) && $1.filter { !$0.isChecked }.isEmpty && (!$2.isEmpty || !$3.isEmpty) && !$4.isEmpty
    }
    .bind(to: output.isEnabledReservationButton)
    .disposed(by: disposeBag)
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireReservationInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapReservationDayCell
      .withLatestFrom(output.selectedDayCollectionViewCellModel) { ($0, $1) }
      .subscribe(with: self) { owner, result in
        let (indexPath, dayModel) = result
        let selectedDayModel = dayModel[indexPath.row]
        guard selectedDayModel.isAvailable else {
          owner.dependency.coordinator.showAlert(message: "예약불가한 날짜입니다.\n다른 날짜를 선택해주세요.")
          return
        }
        owner.selectReservationDay(output: output, indexPath: indexPath)
      }
      .disposed(by: disposeBag)
    
    input.didTapReservationTimeCell
      .withLatestFrom(
        Observable.combineLatest(
          output.amModel,
          output.pmModel
        )
      ) { ($0, $1) }
      .subscribe(with: self) { owner, result in
        let (indexPath, (amModel, pmModel)) = result
        if indexPath.section == 0 { // 오전 시간선택
          let selectedAMModel = amModel[indexPath.row]
          guard !selectedAMModel.isReserved else {
            owner.dependency.coordinator.showAlert(message: "이미 예약된 시간이거나 지난 시간입니다\n다른 시간을 선택해주세요.")
            return
          }
          
          if !selectedAMModel.isTimeSelected {
            guard !owner.isSelectedMaxCount(output: output) else {
              owner.dependency.coordinator.showAlert(message: "예약가능한 최대 개수는 2개입니다.")
              return
            }
          }
        } else { // 오후 시간선택
          let selectedPMModel = pmModel[indexPath.row]
          guard !selectedPMModel.isReserved else {
            owner.dependency.coordinator.showAlert(message: "이미 예약된 시간이거나 지난 시간입니다\n다른 시간을 선택해주세요.")
            return
          }
          
          if !selectedPMModel.isTimeSelected {
            guard !owner.isSelectedMaxCount(output: output) else {
              owner.dependency.coordinator.showAlert(message: "예약가능한 최대 개수는 2개입니다.")
              return
            }
          }
        }
        
        guard owner.isSelectedTimeContinuous(output: output, indexPath: indexPath) else {
          owner.dependency.coordinator.showAlert(message: "연속적인 시간대를 선택해주세요!\n예약은 중간에 비는 시간 없이 가능합니다 😊.")
          return
        }
        
        owner.selectReservationTime(output: output, indexPath: indexPath)
      }
      .disposed(by: disposeBag)
    
    input.didTapTermsOfUseCell
      .subscribe(with: self) { owner, indexPath in
        owner.selectTermsOfUse(output: output, indexPath: indexPath)
      }
      .disposed(by: disposeBag)
    
    input.didTapReservationButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditReservationName,
          input.didEditReservationPhoneNumber,
          output.selectedDayCollectionViewCellModel,
          output.amModel,
          output.pmModel,
          output.policyModel
        )
      )
      .subscribe(with: self) { owner, result in
        let (name, phoneNumber, dayModel, amModel, pmModel, policyModel) = result
        guard let selectedDaySeq = dayModel.first(where: { $0.isSelected })?.calendarSeq else {
          return
        }
        var timeModel = amModel + pmModel
        let selectedTimeSeqList = timeModel.filter { $0.isTimeSelected }
        owner.reserveRothemStudyRoom(
          output: output,
          name: name,
          phoneNumber: phoneNumber,
          selectedDaySeq: selectedDaySeq,
          policyRequests: policyModel.map { .init(policySeq: $0.seq, policyAgreeYn: "Y") },
          selectedTimeSeqList: selectedTimeSeqList.map { $0.timeSeq }
        )
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  private func isSelectedTimeContinuous(output: Output, indexPath: IndexPath) -> Bool {
    let currentAMModel = output.amModel.value
    let currentPMModel = output.pmModel.value
    
    let selectedAMTimeSeqList = currentAMModel.filter { $0.isTimeSelected }.map { $0.timeSeq }
    let selectedPMTimeSeqList = currentPMModel.filter { $0.isTimeSelected }.map { $0.timeSeq }
    let selectedTimeSeqList = selectedAMTimeSeqList + selectedPMTimeSeqList
    
    guard !selectedTimeSeqList.isEmpty else {
      return true
    }
    
    let currentSelectedTimeSeq: Int
    let isCurrentSelected: Bool
    
    if indexPath.section == 0 {
      currentSelectedTimeSeq = currentAMModel[indexPath.row].timeSeq
      isCurrentSelected = currentAMModel[indexPath.row].isTimeSelected
    } else {
      currentSelectedTimeSeq = currentPMModel[indexPath.row].timeSeq
      isCurrentSelected = currentPMModel[indexPath.row].isTimeSelected
    }
    
    guard !isCurrentSelected else {
      return true
    }
    
    let isSelectedTimeContinuous = !selectedTimeSeqList.filter { currentSelectedTimeSeq == $0 - 1 || currentSelectedTimeSeq == $0 + 1 }.isEmpty
    
    return isSelectedTimeContinuous
  }
  
  private func isSelectedMaxCount(output: Output) -> Bool {
    let currentAMModel = output.amModel.value
    let currentPMModel = output.pmModel.value
    
    let selectedAMCount = currentAMModel.filter { $0.isTimeSelected }.count
    let selectedPMCount = currentPMModel.filter { $0.isTimeSelected }.count
    return selectedAMCount + selectedPMCount >= 2
  }
  
  private func selectTermsOfUse(output: Output, indexPath: IndexPath) {
    var currentTermsOfUseModel = output.policyModel.value
    currentTermsOfUseModel[indexPath.row].isChecked.toggle()
    output.policyModel.accept(currentTermsOfUseModel)
  }
  
  private func selectReservationTime(output: Output, indexPath: IndexPath) {
    if indexPath.section == 0 { // 오전 시간 선택/미선택
      var currentAMModel = output.amModel.value
      currentAMModel[indexPath.row].isTimeSelected.toggle()
      output.amModel.accept(currentAMModel)
      
    } else { // 오후 시간 선택/미선택
      var currentPMModel = output.pmModel.value
      currentPMModel[indexPath.row].isTimeSelected.toggle()
      output.pmModel.accept(currentPMModel)
    }
  }
  
  private func selectReservationDay(output: Output, indexPath: IndexPath) {
    var dayModel = output.selectedDayCollectionViewCellModel.value
    var selectedDayModel = dayModel[indexPath.row]
    let isSelected = selectedDayModel.isSelected
    
    guard !isSelected else {
      return
    }
    if let selectedIndex = dayModel.firstIndex(where: { $0.isSelected }) {
      dayModel[selectedIndex].isSelected = false
    }
    
    dayModel[indexPath.row].isSelected = true
    output.selectedDayCollectionViewCellModel.accept(dayModel)
    getTimeInfoForReservation(calendarSeq: selectedDayModel.calendarSeq, output: output)
  }
  
  /// 날짜 선택에 따른 시간정보를 가져오는 함수
  private func getTimeInfoForReservation(calendarSeq: Int, output: Output) {
    let dayModels = output.selectedDayCollectionViewCellModel.value
    let selectedDayModel = dayModels.first(where: { $0.calendarSeq == calendarSeq })!
    
    /// 이용가능한 날짜만 선택가능
    guard selectedDayModel.isAvailable,
          let selectedTimeModel = selectedDayModel.times else { return }
    output.amModel.accept(selectedTimeModel.filter { $0.meridiem == .am }.map { SelectedTimeCollectionViewCellModel(time: $0) })
    output.pmModel.accept(selectedTimeModel.filter { $0.meridiem == .pm }.map { SelectedTimeCollectionViewCellModel(time: $0) })
  }
  
  /// 로뎀 스터디룸을 예약하는 함수
  private func reserveRothemStudyRoom(
    output: Output,
    name: String,
    phoneNumber: String,
    selectedDaySeq: Int,
    policyRequests: [ReservationPolicyRequest],
    selectedTimeSeqList: [Int]
  ) {
    dependency.rothemRepository.reserveStudyRoom(
      roomSeq: payload.roomSeq,
      request: .init(
        userName: name,
        phoneNum: phoneNumber,
        calendarSeq: selectedDaySeq,
        reservationPolicyRequests: policyRequests,
        timeRequests: selectedTimeSeqList.map { TimeRequest(timeSeq: $0) }
      )
    )
    .subscribe(with: self, onSuccess: { owner, response in
      owner.dependency.coordinator.showAlert(message: "축하합니다! 예약이 완료되었습니다 🎉\n메인 화면으로 이동할게요!") {
        owner.dependency.coordinator.popToRothemListViewController()
      }
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
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

extension RothemRoomReservationViewModel {
  /// 예약하기위한 정보를 조회하는 함수, 맨 처음에만 호출
  func inquireReservationInfo(output: Output) {
    let inquireReservationInfo = dependency.rothemRepository.checkTimeAvailableForRothemReservation(roomSeq: payload.roomSeq)
      .do(onSuccess: { _ in
        output.isLoading.onNext(true)
      })
    
    inquireReservationInfo
      .subscribe(with: self, onSuccess: { owner, response in
        output.studyRoomInfoViewModel.accept(StudyRoomInfoViewModel(roomResponse: response.roomResponse))
        output.selectedDayCollectionViewCellModel.accept(response.calendarResponses.map { SelectedDayCollectionViewCellModel(calendarResponse: $0) })
        output.policyModel.accept(response.policyResponses.sorted(by: { $0.policySeq > $1.policySeq }).map { TermsOfUseTableViewCellModel(response: $0) })
        
        
        
        if let availableIndex = response.calendarResponses.firstIndex(where: (\.isAvailable)) {
          owner.selectReservationDay(output: output, indexPath: IndexPath(row: availableIndex, section: 0))
        }
        output.isLoading.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
