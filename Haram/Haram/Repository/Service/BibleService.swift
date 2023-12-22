//
//  BibleService.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift

final class BibleService {
  static let shared = BibleService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension BibleService {
  func inquireTodayWords(request: InquireTodayWordsRequest) -> Single<[InquireTodayWordsResponse]> {
    service.betarequest(router: BibleRouter.inquireTodayWords(request), type: [InquireTodayWordsResponse].self)
  }
  
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Single<[InquireChapterToBibleResponse]> {
    service.betarequest(router: BibleRouter.inquireChapterToBible(request), type: [InquireChapterToBibleResponse].self)
  }
  
  func inquireBibleMainNotice() -> Single<InquireBibleMainNoticeResponse> {
    service.betarequest(router: BibleRouter.inquireBibleMainNotice, type: InquireBibleMainNoticeResponse.self)
  }
}

