//
//  BibleService.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift

protocol BibleRepository {
  func inquireTodayWords(request: InquireTodayWordsRequest) -> Single<[InquireTodayWordsResponse]>
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Single<[InquireChapterToBibleResponse]>
  func inquireBibleMainNotice() -> Single<[InquireBibleMainNoticeResponse]>
  func inquireBibleHomeInfo() -> Single<InquireBibleHomeInfoResponse>
}

final class BibleRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension BibleRepositoryImpl: BibleRepository {
  func inquireTodayWords(request: InquireTodayWordsRequest) -> Single<[InquireTodayWordsResponse]> {
    service.betarequest(router: BibleRouter.inquireTodayWords(request), type: [InquireTodayWordsResponse].self)
  }
  
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Single<[InquireChapterToBibleResponse]> {
    service.betarequest(router: BibleRouter.inquireChapterToBible(request), type: [InquireChapterToBibleResponse].self)
  }
  
  func inquireBibleMainNotice() -> Single<[InquireBibleMainNoticeResponse]> {
    service.betarequest(router: BibleRouter.inquireBibleMainNotice, type: [InquireBibleMainNoticeResponse].self)
  }
  
  func inquireBibleHomeInfo() -> Single<InquireBibleHomeInfoResponse> {
    service.betarequest(router: BibleRouter.inquireBibleHomeInfo, type: InquireBibleHomeInfoResponse.self)
  }
}

