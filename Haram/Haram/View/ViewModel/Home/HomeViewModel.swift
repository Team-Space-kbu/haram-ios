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
  
  var isLoading: Driver<Bool> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let newsModelRelay = BehaviorRelay<[HomeNewsCollectionViewCellModel]>(value: [])
  private let bannerModelRelay = BehaviorRelay<[HomebannerCollectionViewCellModel]>(value: [])
  private let noticeModelRelay = PublishRelay<HomeNoticeViewModel>()
  private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    inquireHomeInfo()
  }
}

extension HomeViewModel {
  private func inquireHomeInfo() {
    let inquireHomeInfo = HomeService.shared.inquireHomeInfo().share()
    
    let inquireSuccessResponse = inquireHomeInfo
      .do(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .compactMap { result -> InquireHomeInfoResponse? in
      guard case let .success(response) = result else { return nil }
      return response
    }
    
    inquireSuccessResponse
      .map { $0.kokkoks.kbuNews.map { HomeNewsCollectionViewCellModel(kbuNews: $0) } }
      .subscribe(with: self) { owner, news in
        owner.newsModelRelay.accept(news)
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
    
    inquireSuccessResponse
      .map { $0.banner.banners.map { HomebannerCollectionViewCellModel(subBanner: $0) } }
      .subscribe(with: self) { owner, banners in
        owner.bannerModelRelay.accept(banners)
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
    
    inquireSuccessResponse
      .compactMap { $0.notice.notice.first }
      .map { HomeNoticeViewModel(subNotice: $0) }
      .subscribe(with: self) { owner, notices in
        owner.noticeModelRelay.accept(notices)
        owner.isLoadingSubject.onNext(false)
      }
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
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
