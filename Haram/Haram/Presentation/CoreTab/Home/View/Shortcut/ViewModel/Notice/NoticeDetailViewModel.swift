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
      let headerString = "<style>img { display: block; margin: auto; max-width: 100%; max-height: 100vh; height: auto; overflow: auto; }</style>"


      
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
