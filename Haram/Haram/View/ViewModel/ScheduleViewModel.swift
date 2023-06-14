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
}

final class ScheduleViewModel: ScheduleViewModelType {
  
  let scheduleInfo: Driver<[ElliottEvent]>
  let inquireSchedule: AnyObserver<Void>
  
  private let disposeBag = DisposeBag()
  
  init() {
    
    let schedulingInfo = BehaviorRelay<[ElliottEvent]>(value: [])
    let inquiringSchedule = PublishSubject<Void>()
    let currentIntranetToken = BehaviorSubject<String?>(value: UserManager.shared.intranetToken)
    let currentXsrfToken = BehaviorSubject<String?>(value: UserManager.shared.xsrfToken)
    let currentLaravelSession = BehaviorSubject<String?>(value: UserManager.shared.laravelSession)
    
    self.scheduleInfo = schedulingInfo.asDriver()
    self.inquireSchedule = inquiringSchedule.asObserver()
    
    inquiringSchedule
      .take(1)
      .withLatestFrom(
        Observable.combineLatest(
          currentIntranetToken,
          currentXsrfToken,
          currentLaravelSession
        ) { ($0, $1, $2) }
      ) { ($1) }
      .flatMapLatest { _ in
        return IntranetService.shared.inquireScheduleInfo(request: .init(
          intranetToken: UserManager.shared.intranetToken!,
          xsrfToken: UserManager.shared.xsrfToken!,
          laravelSession: UserManager.shared.laravelSession!
        )
        )
      }
      .subscribe(onNext: { response in
        let scheduleModel = response.compactMap { model -> ElliottEvent? in
          guard let courseDay = ScheduleDay.allCases.filter { $0.text == model.lectureDay }.first?.elliotDay else { return nil }
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
      })
      .disposed(by: disposeBag)
    //    if UserManager.shared.hasIntranetToken {
    //      inquiringSchedule
    //      .withLatestFrom(
    //        IntranetService.shared.inquireScheduleInfo(
    //          request: .init(
    //            intranetToken: UserManager.shared.intranetToken ?? "",
    //            xsrfToken: UserManager.shared.xsrfToken ?? "",
    //            laravelSession: UserManager.shared.laravelSession ?? ""
    //          ))
    //      )
    //      .subscribe(onNext: { response in
    //        print("응 \(response)")
    //      })
    //      .disposed(by: disposeBag)
  }
}


