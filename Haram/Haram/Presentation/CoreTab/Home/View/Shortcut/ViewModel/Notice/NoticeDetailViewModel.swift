//
//  NoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/28.
//

import RxSwift
import RxCocoa

protocol NoticeDetailViewModelType {
  
  func inquireNoticeDetailInfo(path: String)
  
  var noticeDetailModel: Driver<NoticeDetailModel> { get }

}

final class NoticeDetailViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeDetailModelRelay = PublishRelay<NoticeDetailModel>()
  
  init(noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
    
  }
}

extension NoticeDetailViewModel: NoticeDetailViewModelType {
  
  var noticeDetailModel: RxCocoa.Driver<NoticeDetailModel> {
    noticeDetailModelRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  func inquireNoticeDetailInfo(path: String) {
    noticeRepository.inquireNoticeDetailInfo(
      request: .init(type: .student, path: path)
    )
    .subscribe(with: self) { owner, response in
      
      let iso8607Date = DateformatterFactory.iso8601_2.date(from: response.regDate)!
      let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header><style>img { display: inline; height: auto; max-width: 100%; }</style>"
      
      owner.noticeDetailModelRelay.accept(
        NoticeDetailModel(
          title: response.title,
          writerInfo: DateformatterFactory.noticeWithHypen.string(from: iso8607Date) + " | " + response.name ,
          content: response.content + headerString
        )
      )
      
    }
    .disposed(by: disposeBag)
  }
}
