//
//  ScheduleViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/13.
//

import UIKit

import Elliotable
import RxSwift
import RxCocoa


protocol ScheduleViewModelType {
  
  var inquireSchedule: AnyObserver<Void> { get }
  
  var scheduleInfo: Driver<[ElliottEvent]> { get }
  var isLoading: Driver<Bool> { get }
}

final class ScheduleViewModel: ScheduleViewModelType {
  
  let scheduleInfo: Driver<[ElliottEvent]>
  let inquireSchedule: AnyObserver<Void>
  let isLoading: Driver<Bool>
  
  private let disposeBag = DisposeBag()
  
  init() {
    
    let schedulingInfo = PublishRelay<[ElliottEvent]>()
    let inquiringSchedule = PublishSubject<Void>()
    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    self.scheduleInfo = schedulingInfo.asDriver(onErrorJustReturn: [])
    self.inquireSchedule = inquiringSchedule.asObserver()
    self.isLoading = isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    
    inquiringSchedule
      .filter { UserManager.shared.hasIntranetToken }
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
      .take(1)
      .flatMapLatest(IntranetService.shared.inquireScheduleInfo2)
      .subscribe(onNext: { response in
        let scheduleModel = response.compactMap { model -> ElliottEvent? in
          guard let courseDay = ScheduleDay.allCases.filter({ $0.text == model.lectureDay }).first?.elliotDay else { return nil }
          return ElliottEvent(
            courseId: model.lectureNum,
            courseName: model.subject,
            roomName: model.classRoomName,
            professor: "TEST",
            courseDay: courseDay,
            startTime: model.startTime,
            endTime: model.endTime,
            textColor: UIColor.white,
            backgroundColor: UIColor.ramdomColor
          )
        }
        schedulingInfo.accept(scheduleModel)
        isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}


