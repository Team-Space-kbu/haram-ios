//
//  HomeBannerDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol HomeBannerDetailViewModelType {
  func inquireBannerInfo(bannerSeq: Int)
  
  var bannerInfo: Signal<(title: String, content: String, writerInfo: String)> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class HomeBannerDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let bannerInfoRelay = PublishRelay<(title: String, content: String, writerInfo: String)>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
  }
  
}

extension HomeBannerDetailViewModel: HomeBannerDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var bannerInfo: RxCocoa.Signal<(title: String, content: String, writerInfo: String)> {
    bannerInfoRelay.asSignal()
  }
  
  func inquireBannerInfo(bannerSeq: Int) {
    noticeRepository.inquireNoticeDetail(seq: bannerSeq)
      .subscribe(with: self, onSuccess: { owner, response in
        let iso8607Date = DateformatterFactory.dateForISO8601LocalTimeZone.date(from: response.createdAt)!
        
        owner.bannerInfoRelay.accept(
          (
            title: response.title,
            content: response.content,
            writerInfo: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + response.createdBy
          )
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  
}
