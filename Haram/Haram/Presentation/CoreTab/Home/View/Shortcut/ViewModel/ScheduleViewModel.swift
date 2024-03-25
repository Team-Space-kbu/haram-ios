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
  
  func inquireTimeSchedule()
  
  var scheduleInfo: Driver<[ElliottEvent]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class ScheduleViewModel {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  /// Haram에서 시간표색상에 사용될 리스트
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
  
  /// 강좌에 따라 색상 구분을 해주기위한 딕셔너리
  private var colorInfo: [String: UIColor] = [:]
  
  private let schedulingInfo    = PublishRelay<[ElliottEvent]>()
  private let isLoadingSubject  = BehaviorSubject<Bool>(value: true)
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
  }
}

extension ScheduleViewModel: ScheduleViewModelType {
  
  func inquireTimeSchedule() {
    
    isLoadingSubject.onNext(true)
    
    intranetRepository.inquireScheduleInfo()
      .subscribe(with: self, onSuccess: { owner, response in
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
        owner.schedulingInfo.accept(scheduleModel)
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var scheduleInfo: Driver<[ElliottEvent]> {
    schedulingInfo.asDriver(onErrorJustReturn: [])
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
}
