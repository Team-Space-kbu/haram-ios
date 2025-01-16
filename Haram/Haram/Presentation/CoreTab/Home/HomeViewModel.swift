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
    let viewWillAppear: Observable<Void>
    let didTapBannerCell: Observable<IndexPath>
    let didTapShortcutCell: Observable<IndexPath>
    let didTapNewsCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
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
    
    input.viewWillAppear
      .subscribe(with: self) { owner, _ in
        owner.inquireHomeInfo(output: output)
        owner.inquireSimpleChapelInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireHomeInfo(output: output)
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
  private func inquireSimpleChapelInfo(output: Output) {
    /*
     홈 화면 채플 정보 배너 정보
     1. 오전 10:00 ~ 오후 13:00 시 배너 보임 (이외 시간 배너 안보임)
     */
    
    let startComponents = DateComponents(hour: 10, minute: 0)
    let endComponents = DateComponents(hour: 13, minute: 0)
    
    guard isWithinTimeRange(startComponents: startComponents, endComponents: endComponents) else {
      output.isAvailableSimpleChapelModal.accept((false, nil))
      return
    }
    
    dependency.intranetRepository.inquireChapelInfo()
      .subscribe(with: self, onSuccess: { owner, response in
        let chapelInfo = CheckChapelDayViewModel(regulatedDay: response.regulateDays, chapelDay: response.confirmationDays)
        output.isAvailableSimpleChapelModal.accept((true, chapelInfo))
      }, onFailure: { owner, _ in
        output.isAvailableSimpleChapelModal.accept((false, nil))
      })
      .disposed(by: disposeBag)
  }
  
  private func isWithinTimeRange(
    currentDate: Date = Date(),
    startComponents: DateComponents,
    endComponents: DateComponents
  ) -> Bool {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: currentDate)
    
    guard let startDate = calendar.date(byAdding: startComponents, to: startOfDay),
          let endDate = calendar.date(byAdding: endComponents, to: startOfDay) else {
      return false
    }
    
    return currentDate >= startDate && currentDate <= endDate
  }
}
