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
  func inquireBannerInfo(bannerSeq: Int, department: Department)
  
  var bannerInfo: Signal<(title: String, content: String, thumbnailURL: URL?)> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class HomeBannerDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let homeRepository: HomeRepository
  private let rothemRepository: RothemRepository
  private let bibleRepository: BibleRepository
  
  private let bannerInfoRelay = PublishRelay<(title: String, content: String, thumbnailURL: URL?)>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl(), rothemRepository: RothemRepository = RothemRepositoryImpl(), bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.rothemRepository = rothemRepository
    self.homeRepository = homeRepository
    self.bibleRepository = bibleRepository
  }
  
}

extension HomeBannerDetailViewModel: HomeBannerDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var bannerInfo: RxCocoa.Signal<(title: String, content: String, thumbnailURL: URL?)> {
    bannerInfoRelay.asSignal()
  }
  
  func inquireBannerInfo(bannerSeq: Int, department: Department) {
    switch department {
    case .banners:
      homeRepository.inquireBannerInfo(bannerSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept((title: response.title, content: response.content, thumbnailURL: URL(string: response.thumbnailPath)))
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    case .rothem:
      rothemRepository.inquireRothemNoticeDetail(noticeSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept((title: response.noticeResponse.title, content: response.noticeResponse.content, thumbnailURL: URL(string: response.noticeResponse.thumbnailPath)))
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    case .bibles:
      bibleRepository.inquireBibleDetailInfo(noticeSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept((title: response.title, content: response.content, thumbnailURL: URL(string: response.thumbnailPath)))
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    }
  }
  
  
}
