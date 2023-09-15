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
  func inquireTodayWords(request: InquireTodayWordsRequest) -> Observable<Result<[InquireTodayWordsResponse], HaramError>> {
    service.request(router: BibleRouter.inquireTodayWords(request), type: [InquireTodayWordsResponse].self)
  }
  
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Observable<Result<[InquireChapterToBibleResponse], HaramError>> {
    service.request(router: BibleRouter.inquireChapterToBible(request), type: [InquireChapterToBibleResponse].self)
  }
}

