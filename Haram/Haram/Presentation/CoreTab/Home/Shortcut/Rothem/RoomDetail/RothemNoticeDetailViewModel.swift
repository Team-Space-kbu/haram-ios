//
//  RothemNoticeDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol RothemNoticeDetailViewModelType {
  func inquireRothemNoticeDetail(noticeSeq: Int)
  
  var errorMessage: Signal<HaramError> { get }
  var noticeDetailModel: Signal<(title: String, content: String, thumbnailPath: URL?)> { get }
}

final class RothemNoticeDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let rothemRepository: RothemRepository
  private let noticeDetailModelRelay = PublishRelay<(title: String, content: String, thumbnailPath: URL?)>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(rothemRepository: RothemRepository = RothemRepositoryImpl()) {
    self.rothemRepository = rothemRepository
  }
}

extension RothemNoticeDetailViewModel: RothemNoticeDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var noticeDetailModel: RxCocoa.Signal<(title: String, content: String, thumbnailPath: URL?)> {
    noticeDetailModelRelay.asSignal()
  }
  
  func inquireRothemNoticeDetail(noticeSeq: Int) {
    rothemRepository.inquireRothemNoticeDetail(noticeSeq: noticeSeq)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.noticeDetailModelRelay.accept((title: response.noticeResponse.title, content: response.noticeResponse.content, thumbnailPath: URL(string: response.noticeResponse.thumbnailPath)))
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  
}
