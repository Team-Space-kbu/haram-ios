//
//  EmptyClassViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import Foundation

import RxSwift
import RxCocoa

final class EmptyClassViewModel: ViewModelType {
  let output = Output()
  private let lectureRepository: LectureRepository
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let classModel = BehaviorRelay<[ClassType]>(value: [])
    let alertInfoModel = BehaviorRelay<[AlertInfoViewCellModel]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
  }
  
  init(lectureRepository: LectureRepository = LectureRepositoryImpl()) {
    self.lectureRepository = lectureRepository
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestClassList()
        owner.output.alertInfoModel.accept([
          .init(mainTitle: "조회", mainColor: .hexA8DBA8, title: "강의실 안내", description: "학교 전산에 등록된 데이터 기준으로 표시됩니다."),
          .init(mainTitle: "정보", mainColor: .hexFFB6B6, title: "강의실 정보", description: "학부 강의 기준으로 수업하는 강의실만 표시됩니다.")
        ])
      }
      .disposed(by: disposeBag)
    
//    input.didTappedClassCell
//      .subscribe(with: self) { owner, indexPath in
//        var currentClasses = owner.output.classModel.value
//        let selectedClass = currentClasses[indexPath.row]
////        owner.coordinator.goToCourseListViewController(type: selectedClass)
//      }
//      .disposed(by: disposeBag)
    
    return output
  }
}

extension EmptyClassViewModel {
  private func requestClassList() {
    
    output.isLoading.accept(true)
    
    lectureRepository.inquireEmptyClassBuilding()
      .subscribe(with: self, onSuccess: { owner, response in
        owner.output.classModel.accept(response.compactMap { ClassType(rawValue: $0) })
        owner.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}

enum ClassType: String {
  case milalHall = "밀알관"
  case carmelHall = "갈멜관"
  case moriahHall = "모리아관"
  case illipHall = "일립관"
}
