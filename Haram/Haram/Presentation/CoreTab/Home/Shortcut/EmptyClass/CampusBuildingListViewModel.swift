//
//  CampusBuildingListViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import Foundation

import RxSwift
import RxCocoa

final class CampusBuildingListViewModel: ViewModelType {
  let output = Output()
  private let dependency: Dependency
  private let disposeBag = DisposeBag()
  
  struct Dependency {
    let lectureRepository: LectureRepository
    let coordinator: CampusBuildingListCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapClassRoom: Observable<IndexPath>
    let didTapBackButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let classModel = BehaviorRelay<[ClassType]>(value: [])
    let alertInfoModel = BehaviorRelay<[AlertInfoViewCellModel]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: true)
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestClassList(output: owner.output)
        owner.output.alertInfoModel.accept([
          .init(mainTitle: "조회", mainColor: .hexA8DBA8, title: "강의실 안내", description: "학교 전산에 등록된 데이터 기준으로 표시됩니다."),
          .init(mainTitle: "정보", mainColor: .hexFFB6B6, title: "강의실 정보", description: "학부 강의 기준으로 수업하는 강의실만 표시됩니다.")
        ])
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.requestClassList(output: owner.output)
        owner.output.alertInfoModel.accept([
          .init(mainTitle: "조회", mainColor: .hexA8DBA8, title: "강의실 안내", description: "학교 전산에 등록된 데이터 기준으로 표시됩니다."),
          .init(mainTitle: "정보", mainColor: .hexFFB6B6, title: "강의실 정보", description: "학부 강의 기준으로 수업하는 강의실만 표시됩니다.")
        ])
      }
      .disposed(by: disposeBag)
    
    input.didTapClassRoom
      .subscribe(with: self) { owner, indexPath in
        var currentClasses = owner.output.classModel.value
        let selectedClass = currentClasses[indexPath.row]
        owner.dependency.coordinator.goToLectureListViewController(type: selectedClass)
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

extension CampusBuildingListViewModel {
  private func requestClassList(output: Output) {
    
    output.isLoading.accept(true)
    
    dependency.lectureRepository.inquireEmptyClassBuilding()
      .subscribe(with: self, onSuccess: { owner, response in
        output.classModel.accept(response.compactMap { ClassType(rawValue: $0) })
        output.isLoading.accept(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
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
