//
//  NoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import RxSwift
import RxCocoa

final class NoticeDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let type: NoticeType
    let path: String
  }
  
  struct Dependency {
    let noticeRepository: NoticeRepository
    let coordinator: NoticeDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let noticeDetailModel = PublishRelay<NoticeDetailModel>()
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeDetailInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeDetailInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension NoticeDetailViewModel {
  func inquireNoticeDetailInfo(output: Output) {
    dependency.noticeRepository.inquireNoticeDetailInfo(
      request: .init(type: payload.type, path: payload.path)
    )
    .subscribe(with: self, onSuccess: { owner, response in
      let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: response.regDate)!
      let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
      
      output.noticeDetailModel.accept(
        NoticeDetailModel(
          title: response.title,
          writerInfo: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + response.name ,
          content: response.content + headerString
        )
      )
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
    })
    .disposed(by: disposeBag)
  }
}
