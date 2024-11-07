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
  private let lectureRepository: LectureRepository
  private let payLoad: PayLoad
  private let disposeBag = DisposeBag()
  
  struct PayLoad {
    let classRoom: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTappedLecture: Observable<IndexPath>
  }
  
  struct Output {
    let lectureList = BehaviorRelay<[String]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    let showLectureScheduleViewController = PublishRelay<String>()
  }
  
  init(payLoad: PayLoad, lectureRepository: LectureRepository = LectureRepositoryImpl()) {
    self.payLoad = payLoad
    self.lectureRepository = lectureRepository
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestLectureList(classRoom: owner.payLoad.classRoom)
      }
      .disposed(by: disposeBag)
    
    input.didTappedLecture
      .withUnretained(self)
      .map { owner, indexPath in
        return owner.output.lectureList.value[indexPath.row]
      }
      .subscribe(with: self) { owner, selectedClassRoom in
        owner.output.showLectureScheduleViewController.accept(selectedClassRoom)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension LectureListViewModel {
  private func requestLectureList(classRoom: String) {
    output.isLoading.accept(true)
    
    lectureRepository.inquireEmptyClassList(classRoom: classRoom)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.output.lectureList.accept(response)
        owner.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}
