//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol BoardRepository {
  func inquireBoardlist(boardType: BoardType) -> Single<[InquireBoardlistResponse]>
  func inquireBoard(boardType: BoardType, boardSeq: Int) -> Single<InquireBoardResponse>
  func createComment(request: CreateCommentRequest) -> Single<CreateCommentResponse>
}

final class BoardRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService()) {
    self.service = service
  }
  
}

extension BoardRepositoryImpl: BoardRepository {
  func inquireBoardlist(boardType: BoardType) -> Single<[InquireBoardlistResponse]> {
    service.betarequest(router: BoardRouter.inquireBoardList(boardType), type: [InquireBoardlistResponse].self)
  }
  
  func inquireBoard(boardType: BoardType, boardSeq: Int) -> Single<InquireBoardResponse> {
    service.betarequest(router: BoardRouter.inquireBoard(boardType, boardSeq), type: InquireBoardResponse.self)
  }
  
  func createComment(request: CreateCommentRequest) -> Single<CreateCommentResponse> {
    service.betarequest(router: BoardRouter.createComment(request), type: CreateCommentResponse.self)
  }
}
