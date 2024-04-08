//
//  StudyRoomDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/24/23.
//

import Foundation

import RxSwift
import RxCocoa

protocol StudyRoomDetailViewModelType {
  func inquireRothemRoomInfo(roomSeq: Int)
  var rothemRoomDetailViewModel: Driver<RothemRoomDetailViewModel> { get }
  var rothemRoomThumbnailImage: Driver<URL?> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class StudyRoomDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let rothemRepository: RothemRepository
  
  private let currentRothemRoomDetailViewModelRelay = PublishRelay<RothemRoomDetailViewModel>()
  private let currentRothemRoomThubnailImageRelay   = PublishRelay<URL?>()
  private let errorMessageRelay                     = BehaviorRelay<HaramError?>(value: nil)
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
  
  func inquireRothemRoomInfo(roomSeq: Int) {
    let inquireRothemRoomInfo = rothemRepository.inquireRothemRoomInfo(roomSeq: roomSeq)
    
    inquireRothemRoomInfo
      .subscribe(with: self, onSuccess: { owner, response in
        let rothemRoomThubnailImageURL = URL(string: response.roomResponse.thumbnailPath)
        let rothemRoomDetailViewModel = RothemRoomDetailViewModel(response: response)
        owner.currentRothemRoomDetailViewModelRelay.accept(rothemRoomDetailViewModel)
        owner.currentRothemRoomThubnailImageRelay.accept(rothemRoomThubnailImageURL)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

extension StudyRoomDetailViewModel: StudyRoomDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var rothemRoomDetailViewModel: RxCocoa.Driver<RothemRoomDetailViewModel> {
    currentRothemRoomDetailViewModelRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var rothemRoomThumbnailImage: RxCocoa.Driver<URL?> {
    currentRothemRoomThubnailImageRelay.asDriver(onErrorDriveWith: .empty())
  }

}
