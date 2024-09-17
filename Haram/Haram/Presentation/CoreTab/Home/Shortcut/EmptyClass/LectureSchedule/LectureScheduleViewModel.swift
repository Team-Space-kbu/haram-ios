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
  private let payload: Payload
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
  
  struct Payload {
    let classRoom: String
  }
  
  struct Dependency {
    let lectureRepository: LectureRepository
    let coordinator: LectureScheduleCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    let schedulingInfo    = PublishRelay<[ElliottEvent]>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireLectureSchedule(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension LectureScheduleViewModel {
  private func inquireLectureSchedule(output: Output) {
    dependency.lectureRepository.inquireEmptyClassDetail(classRoom: payload.classRoom)
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
