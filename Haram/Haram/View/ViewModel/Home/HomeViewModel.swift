//
//  HomeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import RxSwift
import RxCocoa

protocol HomeViewModelType {
  var newsModel: Driver<[HomeNewsCollectionViewCellModel]> { get }
  var bannerModel: Driver<[HomebannerCollectionViewCellModel]> { get }
  var noticeModel: Signal<HomeNoticeViewModel> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let newsModelRelay = BehaviorRelay<[HomeNewsCollectionViewCellModel]>(value: [])
  private let bannerModelRelay = BehaviorRelay<[HomebannerCollectionViewCellModel]>(value: [])
  private let noticeModelRelay = PublishRelay<HomeNoticeViewModel>()
  
  init() {
    inquireHomeInfo()
  }
}

extension HomeViewModel {
  private func inquireHomeInfo() {
    let inquireHomeInfo = HomeService.shared.inquireHomeInfo().share()
    
    let inquireSuccessResponse = inquireHomeInfo.compactMap { result -> InquireHomeInfoResponse? in
      guard case let .success(response) = result else { return nil }
      return response
    }
    
    inquireSuccessResponse
      .map { $0.kokkoks.kbuNews.map { HomeNewsCollectionViewCellModel(kbuNews: $0) } }
      .bind(to: newsModelRelay)
      .disposed(by: disposeBag)
    
    inquireSuccessResponse
      .map { $0.banner.banners.map { HomebannerCollectionViewCellModel(subBanner: $0) } }
      .bind(to: bannerModelRelay)
      .disposed(by: disposeBag)
    
    inquireSuccessResponse
      .compactMap { $0.notice.notice.first }
      .map { HomeNoticeViewModel(subNotice: $0) }
      .bind(to: noticeModelRelay)
      .disposed(by: disposeBag)
  }
}

extension HomeViewModel: HomeViewModelType {
  var newsModel: Driver<[HomeNewsCollectionViewCellModel]> {
    newsModelRelay.asDriver()
  }
  var bannerModel: Driver<[HomebannerCollectionViewCellModel]> {
    bannerModelRelay.asDriver()
  }
  var noticeModel: Signal<HomeNoticeViewModel> {
    noticeModelRelay.asSignal()
  }
}
