//
//  HomeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import RxSwift
import RxCocoa

final class HomeViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private var isFetched: Bool = false
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let homeRepository: HomeRepository
    let intranetRepository: IntranetRepository
    let coordinator: HomeCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBannerCell: Observable<IndexPath>
    let didTapShortcutCell: Observable<IndexPath>
    let didTapNewsCell: Observable<IndexPath>
  }
  
  struct Output {
    let newsModel   = PublishRelay<[HomeNewsCollectionViewCellModel]>()
    let bannerModel = PublishRelay<[HomebannerCollectionViewCellModel]>()
    let shortcutModel = PublishRelay<[HomeShortcutCollectionViewCellModel]>()
    let isLoading = PublishRelay<Bool>()
    let isAvailableSimpleChapelModal = PublishRelay<(Bool, CheckChapelDayViewModel?)>()
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireHomeInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBannerCell
      .withLatestFrom(output.bannerModel) { ($0, $1) }
      .map { $0.1[$0.0.row].bannerSeq }
      .subscribe(with: self) { owner, bannerSeq in
        owner.dependency.coordinator.showBannerDetailViewController(bannerSeq: bannerSeq)
      }
      .disposed(by: disposeBag)
    
    input.didTapShortcutCell
      .subscribe(with: self) { owner, indexPath in
        switch ShortcutType.allCases[indexPath.row] {
        case .emptyClass:
          owner.dependency.coordinator.showEmptyClassViewController()
        case .chapel:
          owner.dependency.coordinator.showChapelViewController()
        case .notice:
          owner.dependency.coordinator.showNoticeViewController()
        case .searchBook:
          owner.dependency.coordinator.showLibraryViewController()
        case .coursePlan:
          owner.dependency.coordinator.showCoursePlanViewController()
        case .affiliate:
          owner.dependency.coordinator.showAffiliatedViewController()
        case .schedule:
          owner.dependency.coordinator.showScheduleViewController()
        case .readingRoom:
          owner.dependency.coordinator.showRothemViewController()
        }
      }
      .disposed(by: disposeBag)
    
    input.didTapNewsCell
      .withLatestFrom(output.newsModel) { ($0, $1) }
      .map { $0.1[$0.0.row] }
      .subscribe(with: self) { owner, model in
        owner.dependency.coordinator.showPDFViewController(pdfURL: model.pdfURL, title: model.title)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension HomeViewModel {
  func inquireHomeInfo(output: Output) {
    
    guard !isFetched else { return }
    isFetched = true
    
    output.isLoading.accept(true)
    
    dependency.homeRepository.inquireHomeInfo()
      .subscribe(with: self, onSuccess: { owner, response in
        let news = response.kokkoks.map { HomeNewsCollectionViewCellModel(kokkok: $0) }
        let banners = response.notice.map { HomebannerCollectionViewCellModel(bannerSeq: $0.noticeSeq, imageURL: URL(string: $0.thumbnailPath)) }
        
        output.newsModel.accept(news)
        output.bannerModel.accept(banners)
        output.isLoading.accept(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
        owner.isFetched = false
      })
      .disposed(by: disposeBag)
  }
}

extension HomeViewModel {
//  var errorMessage: RxCocoa.Signal<HaramError> {
//    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
//  }
//  
//  var shortcutModel: RxCocoa.Driver<[HomeShortcutCollectionViewCellModel]> {
//    shortcutModelRelay.asDriver(onErrorJustReturn: [])
//  }
//  
//  var newsModel: Driver<[HomeNewsCollectionViewCellModel]> {
//    newsModelRelay.asDriver(onErrorJustReturn: [])
//  }
//  var bannerModel: Driver<[HomebannerCollectionViewCellModel]> {
//    bannerModelRelay.asDriver(onErrorJustReturn: [])
//  }
//  
//  var isLoading: RxCocoa.Driver<Bool> {
//    isLoadingSubject
//      .distinctUntilChanged()
//      .asDriver(onErrorJustReturn: false)
//  }
//  
//  var isAvailableSimpleChapelModal: Driver<(Bool, CheckChapelDayViewModel?)> {
//    isAvailableSimpleChapelModalSubject
//      .distinctUntilChanged({ $0.0 == $1.0 })
//      .asDriver(onErrorJustReturn: (false, nil))
//  }
//  
//  func inquireSimpleChapelInfo() {
//    // 현재 날짜 및 시간 가져오기
//    let currentDate = Date()
//    
//    // Calendar 및 DateComponents를 사용하여 현재 시간에서 시간 구성 요소 추출
//    let calendar = Calendar.current
//    
//    // 시작 시간 설정 (예: 오전 10시00분)
//    var startComponents = DateComponents()
//    startComponents.hour = 10
//    startComponents.minute = 00
//    
//    // 끝 시간 설정 (예: 오후 1시)
//    var endComponents = DateComponents()
//    endComponents.hour = 13
//    endComponents.minute = 00
//    
//    // 특정 시간과 현재 시간 비교
//    if let startDate = calendar.date(bySettingHour: startComponents.hour!, minute: startComponents.minute!, second: 0, of: currentDate),
//       let endDate = calendar.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: currentDate) {
//      // 현재 시간이 오전 11시30분 ~ 오후 1시일 경우 (startDate, endDate일때는 해당 안됨)
//      
//      if currentDate >= startDate && currentDate <= endDate {
//        intranetRepository.inquireChapelInfo()
//          .subscribe(with: self, onSuccess: { owner, response in
//            owner.isAvailableSimpleChapelModalSubject.onNext((true, .init(regulatedDay: response.regulateDays, chapelDay: response.confirmationDays)))
//          }, onFailure: { owner, _ in
//            owner.isAvailableSimpleChapelModalSubject.onNext((false, nil))
//          }) 
//          .disposed(by: disposeBag)
//      } else {
//        isAvailableSimpleChapelModalSubject.onNext((false, nil))
//      }
//    }
//  }
}
