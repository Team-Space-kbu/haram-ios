//
//  CourseListViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CourseListViewModel: ViewModelType {
  
  let output = Output()
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let course: String
  }
  
  struct Dependency {
    let lectureRepository: LectureRepository
    let coordinator: CourseListCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapLectureCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let lectureList = BehaviorRelay<[LectureInfo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireCoursePlanDetail(output: owner.output, course: owner.payload.course)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireCoursePlanDetail(output: owner.output, course: owner.payload.course)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapLectureCell
      .withLatestFrom(output.lectureList) { (URL(string: $1[$0.row].pdfFile), $1[$0.row].title) }
      .subscribe(with: self) { owner, result in
        let (pdfURL, title) = result
        owner.dependency.coordinator.showPDFViewController(pdfURL: pdfURL, title: title)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension CourseListViewModel {
  private func inquireCoursePlanDetail(output: Output, course: String) {
    output.isLoading.accept(true)
    
    dependency.lectureRepository.inquireCoursePlanDetail(course: course)
      .subscribe(with: self, onSuccess: { owner, response in
        output.lectureList.accept(response.map {
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
        output.isLoading.accept(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
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

