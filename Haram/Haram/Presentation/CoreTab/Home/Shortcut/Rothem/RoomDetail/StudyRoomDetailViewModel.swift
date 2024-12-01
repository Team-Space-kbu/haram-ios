//
//  StudyRoomDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/24/23.
//

import Foundation

import RxSwift
import RxCocoa

final class StudyRoomDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  private(set) var amenityModel: [PopularAmenityCollectionViewCellModel] = []
  
  struct Payload {
    let roomSeq: Int
  }
  
  struct Dependency {
    let rothemRepository: RothemRepository
    let coordinator: StudyRoomDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapReservationButton: Observable<Void>
  }
  
  struct Output {
    let currentRothemRoomDetailViewModelRelay = PublishRelay<RothemRoomDetailViewModel>()
    let currentRothemRoomThubnailImageRelay   = PublishRelay<URL?>()
    let errorMessageRelay                     = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireRothemRoomInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapReservationButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showStudyReservationViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  func inquireRothemRoomInfo(output: Output) {
    let inquireRothemRoomInfo = dependency.rothemRepository.inquireRothemRoomInfo(roomSeq: payload.roomSeq)
    
    inquireRothemRoomInfo
      .subscribe(with: self, onSuccess: { owner, response in
        let rothemRoomThubnailImageURL = URL(string: response.roomResponse.thumbnailPath)
        let rothemRoomDetailViewModel = RothemRoomDetailViewModel(response: response)
        output.currentRothemRoomDetailViewModelRelay.accept(rothemRoomDetailViewModel)
        output.currentRothemRoomThubnailImageRelay.accept(rothemRoomThubnailImageURL)
        owner.amenityModel = response.amenityResponses.map { PopularAmenityCollectionViewCellModel(response: $0) }
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
