//
//  LectureInfoViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/12/24.
//

import RxSwift
import RxCocoa

final class LectureInfoViewModel: ViewModelType {
  
  let output = Output()
  private let disposeBag = DisposeBag()
  private let lectureRepository: LectureRepository
  private let payLoad: PayLoad
  
  struct PayLoad {
    let course: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let lectureList = BehaviorRelay<[LectureInfo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
  }
  
  init(payLoad: PayLoad, lectureRepository: LectureRepository) {
    self.payLoad = payLoad
    self.lectureRepository = lectureRepository
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireCoursePlanDetail(course: owner.payLoad.course)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension LectureInfoViewModel {
  private func inquireCoursePlanDetail(course: String) {
    output.isLoading.accept(true)
    
    lectureRepository.inquireCoursePlanDetail(course: course)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.output.lectureList.accept(response.map {
          .init(
            pdfFile: $0.lectureFile,
            title: $0.subject,
            professorName: $0.profName,
            types: [
              $0.classRoomName,
              $0.lectureNum,
              $0.lectureDay
            ])
        })
        owner.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}

struct LectureInfo {
  let pdfFile: String
  let title: String
  let professorName: String
  let types: [String]
}

