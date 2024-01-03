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
  var scheduleInfo: Driver<[ElliottEvent]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class ScheduleViewModel: ScheduleViewModelType {
  
  let scheduleInfo: Driver<[ElliottEvent]>
  let isLoading: Driver<Bool>
  let errorMessage: Signal<HaramError>
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
    
    let schedulingInfo    = PublishRelay<[ElliottEvent]>()
    let isLoadingSubject  = BehaviorSubject<Bool>(value: true)
    let errorMessageSubject = PublishSubject<HaramError>()
    
    self.scheduleInfo = schedulingInfo.asDriver(onErrorJustReturn: [])
    self.isLoading = isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    self.errorMessage = errorMessageSubject.asSignal(onErrorSignalWith: .empty())
    
    intranetRepository.inquireScheduleInfo()
      .do(onSuccess: { _ in isLoadingSubject.onNext(true) })
      .subscribe(onSuccess: { response in
        let scheduleModel = response.compactMap { model -> ElliottEvent? in
          guard let courseDay = Day.allCases.filter({ $0.text == model.lectureDay }).first?.elliotDay else { return nil }
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
      }, onFailure: { error in
        guard let error = error as? HaramError else { return }
        errorMessageSubject.onNext(error)
        isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}


