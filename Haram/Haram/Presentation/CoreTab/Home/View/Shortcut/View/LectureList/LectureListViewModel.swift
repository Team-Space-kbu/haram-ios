//
//  LectureListViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/10/24.
//

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
  }
  
  struct Output {
    let lectureList = BehaviorRelay<[String]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
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
