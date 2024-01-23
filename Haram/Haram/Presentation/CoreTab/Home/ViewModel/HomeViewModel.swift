//
//  HomeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import Foundation

import RxSwift
import RxCocoa

protocol HomeViewModelType {
  
  func inquireSimpleChapelInfo()
  
  var newsModel: Driver<[HomeNewsCollectionViewCellModel]> { get }
  var bannerModel: Driver<[HomebannerCollectionViewCellModel]> { get }
  var noticeModel: Driver<HomeNoticeViewModel> { get }
  var shortcutModel: Driver<[HomeShortcutCollectionViewCellModel]> { get }
  
  var isLoading: Driver<Bool> { get }
  var isAvailableSimpleChapelModal: Driver<Bool> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  private let homeRepository: HomeRepository
  
  private let newsModelRelay   = BehaviorRelay<[HomeNewsCollectionViewCellModel]>(value: [])
  private let bannerModelRelay = BehaviorRelay<[HomebannerCollectionViewCellModel]>(value: [])
  private let shortcutModelRelay = BehaviorRelay<[HomeShortcutCollectionViewCellModel]>(value: [])
  private let noticeModelRelay = PublishRelay<HomeNoticeViewModel>()
  private let isLoadingSubject = PublishSubject<Bool>()
  private let isAvailableSimpleChapelModalSubject = PublishSubject<Bool>()
  
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
  var noticeModel: Driver<HomeNoticeViewModel> {
    noticeModelRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  var isAvailableSimpleChapelModal: Driver<Bool> {
    isAvailableSimpleChapelModalSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  func inquireSimpleChapelInfo() {
    // 현재 날짜 및 시간 가져오기
    let currentDate = Date()
    
    // Calendar 및 DateComponents를 사용하여 현재 시간에서 시간 구성 요소 추출
    let calendar = Calendar.current
    //      let components = calendar.dateComponents([.hour, .minute], from: currentDate)
    
    // 시작 시간 설정 (예: 오전 11시30분)
    var startComponents = DateComponents()
    startComponents.hour = 20
    startComponents.minute = 48
    
    // 끝 시간 설정 (예: 오후 1시)
    var endComponents = DateComponents()
    endComponents.hour = 20
    endComponents.minute = 50
    
    // 특정 시간과 현재 시간 비교
    if let startDate = calendar.date(bySettingHour: startComponents.hour!, minute: startComponents.minute!, second: 0, of: currentDate),
       let endDate = calendar.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: currentDate) {
      // 현재 시간이 오전 11시30분 ~ 오후 1시일 경우 (startDate, endDate일때는 해당 안됨)
      isAvailableSimpleChapelModalSubject.onNext(currentDate >= startDate && currentDate <= endDate)
    }
  }
}
