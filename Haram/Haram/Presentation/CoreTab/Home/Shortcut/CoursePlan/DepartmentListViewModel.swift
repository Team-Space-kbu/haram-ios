//
//  DepartmentListViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/9/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DepartmentListViewModel: ViewModelType {

  private let dependency: Dependency
  let output = Output()
  private let disposeBag = DisposeBag()
  
  struct Dependency {
    let lectureRepository: LectureRepository
    let coordinator: DepartmentListCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapMajorCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let majorList = BehaviorRelay<[MajorInfo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestMajorList(output: owner.output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.requestMajorList(output: owner.output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapMajorCell
      .withLatestFrom(output.majorList) { $1[$0.row] }
      .subscribe(with: self) { owner, major in
        let course = major.courseKey
        let title = major.type.rawValue
        owner.dependency.coordinator.showLectureInfoViewController(course: course, title: title)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension DepartmentListViewModel {
  private func requestMajorList(output: Output) {
    output.isLoading.accept(true)
    
    dependency.lectureRepository.inquireCoursePlanList()
      .subscribe(with: self, onSuccess: { owner, response in
        output.majorList.accept(response.map {
          .init(type: MajorType(rawValue: $0.title) ?? .other, courseKey: $0.key)
        })
        output.isLoading.accept(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
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
