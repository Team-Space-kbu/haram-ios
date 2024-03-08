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
  private var backgroundColorList: [UIColor] = [
    .hex83A3E4,
    .hexE28B7B,
    .hex9B87DB,
    .hex8BC88E,
    .hexF0AF72,
    .hex90CFC1,
    .hexF2D96D,
    .hexD397ED,
    .hexA7CA70
  ]
  private var colorInfo: [String: UIColor] = [:]
  
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
      .subscribe(onSuccess: { [weak self] response in
        guard let self = self else { return }
        let scheduleModel = response
          .enumerated()
          .compactMap { index, model -> ElliottEvent? in
          guard let courseDay = Day.allCases.filter({ $0.text == model.lectureDay }).first?.elliotDay else { return nil }
          
          if self.colorInfo[model.lectureNum] == nil {
            self.colorInfo[model.lectureNum] = self.backgroundColorList[index % self.backgroundColorList.count]
          }
          
          return ElliottEvent(
            courseId: model.lectureNum,
            courseName: model.subject,
            roomName: model.classRoomName,
            professor: "TEST",
            courseDay: courseDay,
            startTime: model.startTime,
            endTime: model.endTime,
            textColor: UIColor.white,
            backgroundColor: self.colorInfo[model.lectureNum]!
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


