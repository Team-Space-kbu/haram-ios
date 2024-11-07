//
//  LectureScheduleViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/6/24.
//

import Foundation

import Elliotable
import RxSwift
import RxCocoa

final class LectureScheduleViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let payLoad: PayLoad
  private let dependency: Dependency
  
  private(set) var courseModel: [ElliottEvent] = []
  
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
  
  struct PayLoad {
    let classRoom: String
  }
  
  struct Dependency {
    let lectureRepository: LectureRepository
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let schedulingInfo    = PublishRelay<[ElliottEvent]>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(payLoad: PayLoad, dependency: Dependency) {
    self.payLoad = payLoad
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireLectureSchedule(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension LectureScheduleViewModel {
  private func inquireLectureSchedule(output: Output) {
    dependency.lectureRepository.inquireEmptyClassDetail(classRoom: payLoad.classRoom)
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
        owner.courseModel = scheduleModel
        output.schedulingInfo.accept(scheduleModel)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
