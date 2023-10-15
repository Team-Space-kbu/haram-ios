//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

final class BoardService {
  
  static let shared = BoardService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension BoardService {
  func inquireBoardlist(boardType: BoardType) -> Observable<Result<[InquireBoardlistResponse], HaramError>> {
    service.request(router: BoardRouter.inquireBoardList(boardType), type: [InquireBoardlistResponse].self)
  }
}
