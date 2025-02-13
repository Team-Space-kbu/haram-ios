//
//  HomeBannerDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

import RxSwift
import RxCocoa

final class HomeBannerDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let bannerSeq: Int
  }
  
  struct Dependency {
    let noticeRepository: NoticeRepository
    let coordinator: BannerDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let bannerInfo = PublishRelay<(title: String, content: String, writerInfo: String)>()
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.didConnectNetwork.asObservable()
    )
      .subscribe(with: self) { owner, _ in
        owner.inquireBannerInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension HomeBannerDetailViewModel {
  func inquireBannerInfo(output: Output) {
    dependency.noticeRepository.inquireNoticeDetail(seq: payload.bannerSeq)
      .subscribe(with: self, onSuccess: { owner, response in
        let iso8607Date = DateformatterFactory.dateForISO8601LocalTimeZone.date(from: response.createdAt)!
        
        output.bannerInfo.accept(
          (
            title: response.title,
            content: response.content,
            writerInfo: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + response.createdBy
          )
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
