//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol BoardRepository {
  
  func inquireBoardCategory() -> Single<[InquireBoardCategoryResponse]>
  func inquireBoardListInCategory(categorySeq: Int) -> Single<InquireBoardListInCategoryResponse>
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int) -> Single<InquireBoardDetailResponse>
  func createBoard(categorySeq: Int, request: CreateBoardRequest) -> Single<Bool>
  func createComment(request: CreateCommentRequest, categorySeq: Int, boardSeq: Int) -> Single<[Comment]>
  
}

final class BoardRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension BoardRepositoryImpl: BoardRepository {
  func createBoard(categorySeq: Int, request: CreateBoardRequest) -> RxSwift.Single<Bool> {
    service.betarequest(router: BoardRouter.createBoard(categorySeq, request), type: Bool.self)
  }
  
  func inquireBoardCategory() -> RxSwift.Single<[InquireBoardCategoryResponse]> {
    service.betarequest(router: BoardRouter.inquireBoardCategory, type: [InquireBoardCategoryResponse].self)
  }
  
  func inquireBoardListInCategory(categorySeq: Int) -> RxSwift.Single<InquireBoardListInCategoryResponse> {
    service.betarequest(router: BoardRouter.inquireBoardListInCategory(categorySeq), type: InquireBoardListInCategoryResponse.self)
  }
  
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int) -> RxSwift.Single<InquireBoardDetailResponse> {
    service.betarequest(router: BoardRouter.inquireBoardDetail(categorySeq, boardSeq), type: InquireBoardDetailResponse.self)
  }
  
  func createComment(request: CreateCommentRequest, categorySeq: Int, boardSeq: Int) -> RxSwift.Single<[Comment]> {
    service.betarequest(router: BoardRouter.createComment(request, categorySeq, boardSeq), type: [Comment].self)
  }
  
  
}
