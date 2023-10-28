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
  func inquireBoardlist(boardType: BoardType) -> Single<[InquireBoardlistResponse]> {
    service.betarequest(router: BoardRouter.inquireBoardList(boardType), type: [InquireBoardlistResponse].self)
  }
  
  func inquireBoard(boardType: BoardType, boardSeq: Int) -> Single<InquireBoardResponse> {
    service.betarequest(router: BoardRouter.inquireBoard(boardType, boardSeq), type: InquireBoardResponse.self)
  }
}
