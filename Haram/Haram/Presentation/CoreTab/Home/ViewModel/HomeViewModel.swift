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
  var shortcutModel: Driver<[HomeShortcutCollectionViewCellModel]> { get }
  
  var isLoading: Driver<Bool> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  private let homeRepository: HomeRepository
  
  private let newsModelRelay   = BehaviorRelay<[HomeNewsCollectionViewCellModel]>(value: [])
  private let bannerModelRelay = BehaviorRelay<[HomebannerCollectionViewCellModel]>(value: [])
  private let shortcutModelRelay = BehaviorRelay<[HomeShortcutCollectionViewCellModel]>(value: [])
  private let noticeModelRelay = PublishRelay<HomeNoticeViewModel>()
  private let isLoadingSubject = PublishSubject<Bool>()
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl()) {
    self.homeRepository = homeRepository
    inquireHomeInfo()
  }
}

extension HomeViewModel {
  private func inquireHomeInfo() {
    let inquireHomeInfo = homeRepository.inquireHomeInfo()
    
    inquireHomeInfo
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .subscribe(with: self) { owner, response in
        guard let subNotice = response.notice.notices.first else { return }
        let news = response.kokkoks.kokkoksNews.map { HomeNewsCollectionViewCellModel(kokkoksNews: $0) }
        let banners = response.banner.banners.map { HomebannerCollectionViewCellModel(subBanner: $0) }
        let notices = HomeNoticeViewModel(subNotice: subNotice)
        let shortcut = response.homes
        
        owner.newsModelRelay.accept(news)
        owner.bannerModelRelay.accept(banners)
        owner.noticeModelRelay.accept(notices)
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

extension HomeViewModel: HomeViewModelType {
  var shortcutModel: RxCocoa.Driver<[HomeShortcutCollectionViewCellModel]> {
    shortcutModelRelay.asDriver()
  }
  
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
