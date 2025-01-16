//
//  RothemRoomDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/24/23.
//

import Foundation

import RxSwift
import RxCocoa

final class RothemRoomDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  private(set) var amenityModel: [PopularAmenityCollectionViewCellModel] = []
  
  struct Payload {
    let roomSeq: Int
  }
  
  struct Dependency {
    let rothemRepository: RothemRepository
    let coordinator: RothemRoomDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapReservationButton: Observable<Void>
    let didTapRothemThumbnail: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let currentRothemRoomDetailViewModel = PublishRelay<(roomTitle: String, roomDestination: String, roomDescription: String)>()
    let currentRothemRoomThubnailImage   = PublishRelay<URL?>()
    let errorMessage                     = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.didConnectNetwork.asObservable()
    )
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
    
    input.didTapRothemThumbnail
      .withLatestFrom(output.currentRothemRoomThubnailImage)
      .subscribe(with: self) { owner, imageURL in
        guard let imageURL = imageURL else {
          owner.dependency.coordinator.showAlert(message: "해당 이미지는 확대할 수 없습니다")
          return
        }
        owner.dependency.coordinator.showZoomImageViewController(imageURL: imageURL)
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  func inquireRothemRoomInfo(output: Output) {
    let inquireRothemRoomInfo = dependency.rothemRepository.inquireRothemRoomInfo(roomSeq: payload.roomSeq)
    
    inquireRothemRoomInfo
      .subscribe(with: self, onSuccess: { owner, response in
        let rothemRoomThubnailImageURL = URL(string: response.roomResponse.thumbnailPath)
        let rothemRoomDetailViewModel = (roomTitle: response.roomResponse.roomName, roomDestination: response.roomResponse.location, roomDescription: response.roomResponse.roomExplanation)
        output.currentRothemRoomDetailViewModel.accept(rothemRoomDetailViewModel)
        output.currentRothemRoomThubnailImage.accept(rothemRoomThubnailImageURL)
        owner.amenityModel = response.amenityResponses.map { PopularAmenityCollectionViewCellModel(response: $0) }
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
