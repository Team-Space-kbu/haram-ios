//
//  CoursePlanViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/9/24.
//

import RxSwift
import RxCocoa

final class CoursePlanViewModel: ViewModelType {

  private let lectureRepository: LectureRepository
  let output = Output()
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let majorList = BehaviorRelay<[MajorInfo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
  }
  
  init(lectureRepository: LectureRepository = LectureRepositoryImpl()) {
    self.lectureRepository = lectureRepository
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestMajorList()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension CoursePlanViewModel {
  private func requestMajorList() {
    output.isLoading.accept(true)
    
    lectureRepository.inquireCoursePlanList()
      .subscribe(with: self, onSuccess: { owner, response in
        owner.output.majorList.accept(response.map {
          .init(type: MajorType(rawValue: $0.title) ?? .other, courseKey: $0.key)
        })
        owner.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}

struct MajorInfo {
  let type: MajorType
  let courseKey: String
}

enum MajorType: String {
  case computer = "컴퓨터소프트웨어학과"
  case nursing = "간호학과"
  case childhood = "영유아보육학과"
  case social = "사회복지학과"
  case seongseo = "성서학과"
  case illip = "일립교육원"
  case education = "교직부"
  case other = "정보없음"
}
