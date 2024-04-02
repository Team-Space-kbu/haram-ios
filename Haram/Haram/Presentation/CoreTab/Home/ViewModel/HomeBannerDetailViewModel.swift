//
//  HomeBannerDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import RxSwift
import RxCocoa

protocol HomeBannerDetailViewModelType {
  func inquireBannerInfo(bannerSeq: Int)
  
  var bannerInfo: Signal<(title: String, content: String)> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class HomeBannerDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let homeRepository: HomeRepository
  
  private let bannerInfoRelay = PublishRelay<(title: String, content: String)>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl()) {
    self.homeRepository = homeRepository
  }
  
}

extension HomeBannerDetailViewModel: HomeBannerDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var bannerInfo: RxCocoa.Signal<(title: String, content: String)> {
    bannerInfoRelay.asSignal()
  }
  
  func inquireBannerInfo(bannerSeq: Int) {
    
    homeRepository.inquireBannerInfo(bannerSeq: bannerSeq)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.bannerInfoRelay.accept((title: response.title, content: response.content))
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  
}
