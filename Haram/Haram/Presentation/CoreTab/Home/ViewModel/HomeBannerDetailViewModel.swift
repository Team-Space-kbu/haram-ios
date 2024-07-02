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
  func inquireBannerInfo()
  
  var bannerInfo: Signal<(title: String, content: String, imageModel: [HomebannerCollectionViewCellModel])> { get }
  var errorMessage: Signal<HaramError> { get }
  var bannerDetailType: BannerDetailType { get }
}

final class HomeBannerDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let bannerSeq: Int
  private let department: Department
  private let homeRepository: HomeRepository
  private let rothemRepository: RothemRepository
  private let bibleRepository: BibleRepository
  var bannerDetailType: BannerDetailType
  
  private let bannerInfoRelay = PublishRelay<(title: String, content: String, imageModel: [HomebannerCollectionViewCellModel])>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(bannerDetailType: BannerDetailType, department: Department, bannerSeq: Int, homeRepository: HomeRepository = HomeRepositoryImpl(), rothemRepository: RothemRepository = RothemRepositoryImpl(), bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.rothemRepository = rothemRepository
    self.homeRepository = homeRepository
    self.bibleRepository = bibleRepository
    self.bannerSeq = bannerSeq
    self.department = department
    self.bannerDetailType = bannerDetailType
  }
  
}

extension HomeBannerDetailViewModel: HomeBannerDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var bannerInfo: RxCocoa.Signal<(title: String, content: String, imageModel: [HomebannerCollectionViewCellModel])> {
    bannerInfoRelay.asSignal()
  }
  
  func inquireBannerInfo() {
    switch department {
    case .banners:
      homeRepository.inquireBannerInfo(bannerSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept(
            (
              title: response.title,
              content: response.content,
              imageModel: response.bannerFileResponses.map { HomebannerCollectionViewCellModel(response: $0) }
            )
          )
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    case .rothem:
      rothemRepository.inquireRothemNoticeDetail(noticeSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept(
            (
              title: response.noticeResponse.title,
              content: response.noticeResponse.content,
              imageModel: response.noticeFileResponses.map { HomebannerCollectionViewCellModel(response: $0) }
            )
          )
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    case .bibles:
      bibleRepository.inquireBibleDetailInfo(noticeSeq: bannerSeq)
        .subscribe(with: self, onSuccess: { owner, response in
          owner.bannerInfoRelay.accept(
            (
              title: response.title,
              content: response.content,
              imageModel: response.bibleNoticeFileResponses.map { HomebannerCollectionViewCellModel(response: $0) }
            )
          )
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          owner.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    }
  }
  
  
}
