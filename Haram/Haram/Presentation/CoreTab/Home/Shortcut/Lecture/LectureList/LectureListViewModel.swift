//
//  LectureListViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/10/24.
//

import Foundation

import RxSwift
import RxCocoa

final class LectureListViewModel: ViewModelType {

  let output = Output()
  private let dependency: Dependency
  private let payload: Payload
  private let disposeBag = DisposeBag()
  
  struct Payload {
    let classRoom: String
  }
  
  struct Dependency {
    let lectureRepository: LectureRepository
    let coordinator: LectureListCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTappedLecture: Observable<IndexPath>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    let lectureList = BehaviorRelay<[String]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestLectureList(classRoom: owner.payload.classRoom)
      }
      .disposed(by: disposeBag)
    
    input.didTappedLecture
      .withUnretained(self)
      .map { owner, indexPath in
        return owner.output.lectureList.value[indexPath.row]
      }
      .subscribe(with: self) { owner, selectedClassRoom in
        owner.dependency.coordinator.showLectureScheduleViewController(classRoom: selectedClassRoom)
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

extension LectureListViewModel {
  private func requestLectureList(classRoom: String) {
    output.isLoading.accept(true)
    
    dependency.lectureRepository.inquireEmptyClassList(classRoom: classRoom)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.output.lectureList.accept(response)
        owner.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}
