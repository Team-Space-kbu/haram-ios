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
  var rothemRoomDetailViewModel: Driver<RothemRoomDetailViewModel> { get }
  var rothemRoomThumbnailImage: Driver<URL?> { get }
}

final class StudyRoomDetailViewModel {
  
  private let roomSeq: Int
  private let disposeBag = DisposeBag()
  private let currentRothemRoomDetailViewModelRelay = PublishRelay<RothemRoomDetailViewModel>()
  private let currentRothemRoomThubnailImageRelay   = PublishRelay<URL?>()
  
  init(roomSeq: Int) {
    self.roomSeq = roomSeq
    inquireRothemRoomInfo()
  }
  
  private func inquireRothemRoomInfo() {
    let inquireRothemRoomInfo = RothemService.shared.inquireRothemRoomInfo(roomSeq: roomSeq)
    
    inquireRothemRoomInfo
      .subscribe(with: self) { owner, response in
        let rothemRoomThubnailImageURL = URL(string: response.rooomResponse.thumbnailPath)
        let rothemRoomDetailViewModel = RothemRoomDetailViewModel(response: response)
        owner.currentRothemRoomDetailViewModelRelay.accept(rothemRoomDetailViewModel)
        owner.currentRothemRoomThubnailImageRelay.accept(rothemRoomThubnailImageURL)
      }
      .disposed(by: disposeBag)
  }
}

extension StudyRoomDetailViewModel: StudyRoomDetailViewModelType {
  var rothemRoomDetailViewModel: RxCocoa.Driver<RothemRoomDetailViewModel> {
    currentRothemRoomDetailViewModelRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var rothemRoomThumbnailImage: RxCocoa.Driver<URL?> {
    currentRothemRoomThubnailImageRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  
}
