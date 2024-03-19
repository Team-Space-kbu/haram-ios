//
//  HomeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import RxSwift
import RxCocoa

protocol HomeViewModelType {
  
  func inquireSimpleChapelInfo()
  func inquireHomeInfo()
  
  var newsModel: Driver<[HomeNewsCollectionViewCellModel]> { get }
  var bannerModel: Driver<[HomebannerCollectionViewCellModel]> { get }
  var noticeModel: Driver<HomeNoticeViewModel> { get }
  var shortcutModel: Driver<[HomeShortcutCollectionViewCellModel]> { get }
  
  var isLoading: Driver<Bool> { get }
  var isAvailableSimpleChapelModal: Driver<(Bool, CheckChapelDayViewModel?)> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class HomeViewModel {
  
  private let disposeBag = DisposeBag()
  private let homeRepository: HomeRepository
  private let intranetRepository: IntranetRepository
  
  private let newsModelRelay   = BehaviorRelay<[HomeNewsCollectionViewCellModel]>(value: [])
  private let bannerModelRelay = BehaviorRelay<[HomebannerCollectionViewCellModel]>(value: [])
  private let shortcutModelRelay = BehaviorRelay<[HomeShortcutCollectionViewCellModel]>(value: [])
  private let noticeModelRelay = PublishRelay<HomeNoticeViewModel>()
  private let isLoadingSubject = PublishSubject<Bool>()
  private let isAvailableSimpleChapelModalSubject = PublishSubject<(Bool, CheckChapelDayViewModel?)>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl(), intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.homeRepository = homeRepository
    self.intranetRepository = intranetRepository
    inquireHomeInfo()
  }
}

extension HomeViewModel {
  func inquireHomeInfo() {
    
    let inquireHomeInfo = homeRepository.inquireHomeInfo()
    
    inquireHomeInfo
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .subscribe(with: self, onSuccess: { owner, response in
        guard let subNotice = response.notice.notices.first else { return }
        let news = response.kokkoks.kokkoksNews.map { HomeNewsCollectionViewCellModel(kokkoksNews: $0) }
        let banners = response.banner.banners.map { HomebannerCollectionViewCellModel(subBanner: $0) }
        let notices = HomeNoticeViewModel(subNotice: subNotice)
//        let shortcuts = response.homes.map { HomeShortcutCollectionViewCellModel(title: $0.iconName.replacingOccurrences(of: ".svg", with: ""), imageURL: URL(string: $0.iconFilePath)) }
        
        owner.newsModelRelay.accept(news)
        owner.bannerModelRelay.accept(banners)
        owner.noticeModelRelay.accept(notices)
//        owner.shortcutModelRelay.accept(shortcuts)
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

extension HomeViewModel: HomeViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
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
  
  var isAvailableSimpleChapelModal: Driver<(Bool, CheckChapelDayViewModel?)> {
    isAvailableSimpleChapelModalSubject
      .distinctUntilChanged({ $0.0 == $1.0 })
      .asDriver(onErrorJustReturn: (false, nil))
  }
  
  func inquireSimpleChapelInfo() {
    // 현재 날짜 및 시간 가져오기
    let currentDate = Date()
    
    // Calendar 및 DateComponents를 사용하여 현재 시간에서 시간 구성 요소 추출
    let calendar = Calendar.current
    //      let components = calendar.dateComponents([.hour, .minute], from: currentDate)
    
    // 시작 시간 설정 (예: 오전 11시30분)
    var startComponents = DateComponents()
    startComponents.hour = 11
    startComponents.minute = 30
    
    // 끝 시간 설정 (예: 오후 1시)
    var endComponents = DateComponents()
    endComponents.hour = 13
    endComponents.minute = 00
    
    // 특정 시간과 현재 시간 비교
    if let startDate = calendar.date(bySettingHour: startComponents.hour!, minute: startComponents.minute!, second: 0, of: currentDate),
       let endDate = calendar.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: currentDate) {
      // 현재 시간이 오전 11시30분 ~ 오후 1시일 경우 (startDate, endDate일때는 해당 안됨)
      
      if currentDate >= startDate && currentDate <= endDate {
        intranetRepository.inquireChapelInfo()
          .subscribe(with: self) { owner, result in
            switch result {
            case .success(let response):
              owner.isAvailableSimpleChapelModalSubject.onNext((true, .init(regulatedDay: response.regulateDays, chapelDay: response.confirmationDays)))
            case .failure(let _):
              owner.isAvailableSimpleChapelModalSubject.onNext((false, nil))
            }
          }
          .disposed(by: disposeBag)
      } else {
        isAvailableSimpleChapelModalSubject.onNext((false, nil))
      }
      
//      isAvailableSimpleChapelModalSubject.onNext(currentDate >= startDate && currentDate <= endDate)
    }
  }
}
