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
  private let noticeRepository: NoticeRepository
  private let payLoad: PayLoad
  
  struct PayLoad {
    let type: NoticeType
    let path: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let noticeDetailModelRelay = PublishRelay<NoticeDetailModel>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl(), payLoad: PayLoad) {
    self.noticeRepository = noticeRepository
    self.payLoad = payLoad
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeDetailInfo(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension NoticeDetailViewModel {
  func inquireNoticeDetailInfo(output: Output) {
    noticeRepository.inquireNoticeDetailInfo(
      request: .init(type: payLoad.type, path: payLoad.path)
    )
    .subscribe(with: self, onSuccess: { owner, response in
      let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: response.regDate)!
      let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
      
      output.noticeDetailModelRelay.accept(
        NoticeDetailModel(
          title: response.title,
          writerInfo: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + response.name ,
          content: response.content + headerString
        )
      )
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessageRelay.accept(error)
    })
    .disposed(by: disposeBag)
  }
}
