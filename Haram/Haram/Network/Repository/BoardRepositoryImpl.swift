//
//  MyPageService.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import RxSwift

protocol BoardRepository {
  
  func inquireBoardCategory() -> Single<[InquireBoardCategoryResponse]>
  func inquireBoardListInCategory(categorySeq: Int, page: Int) -> Single<InquireBoardListInCategoryResponse>
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int) -> Single<InquireBoardDetailResponse>
  func createBoard(categorySeq: Int, request: CreateBoardRequest) -> Single<Bool>
  func createComment(request: CreateCommentRequest, categorySeq: Int, boardSeq: Int) -> Single<[Comment]>
  func reportBoard(request: ReportBoardRequest) -> Single<EmptyModel>
  func deleteBoard(categorySeq: Int, boardSeq: Int) -> Single<EmptyModel>
  func deleteComment(categorySeq: Int, boardSeq: Int, commentSeq: Int) -> Single<[Comment]>
  func bannedUser(boardSeq: Int) -> Single<EmptyModel>
}

final class BoardRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension BoardRepositoryImpl: BoardRepository {
  func bannedUser(boardSeq: Int) -> RxSwift.Single<EmptyModel> {
    service.request(router: BoardRouter.bannedUser(boardSeq), type: EmptyModel.self)
  }
  
  func deleteBoard(categorySeq: Int, boardSeq: Int) -> RxSwift.Single<EmptyModel> {
    service.request(router: BoardRouter.deleteBoard(categorySeq, boardSeq), type: EmptyModel.self)
  }
  
  func deleteComment(categorySeq: Int, boardSeq: Int, commentSeq: Int) -> RxSwift.Single<[Comment]> {
    service.request(router: BoardRouter.deleteComment(categorySeq, boardSeq, commentSeq), type: [Comment].self)
  }
  
  func reportBoard(request: ReportBoardRequest) -> RxSwift.Single<EmptyModel> {
    service.request(router: BoardRouter.reportBoard(request), type: EmptyModel.self)
  }
  
  func createBoard(categorySeq: Int, request: CreateBoardRequest) -> RxSwift.Single<Bool> {
    service.request(router: BoardRouter.createBoard(categorySeq, request), type: Bool.self)
  }
  
  func inquireBoardCategory() -> RxSwift.Single<[InquireBoardCategoryResponse]> {
    service.request(router: BoardRouter.inquireBoardCategory, type: [InquireBoardCategoryResponse].self)
  }
  
  func inquireBoardListInCategory(categorySeq: Int, page: Int = 1) -> RxSwift.Single<InquireBoardListInCategoryResponse> {
    service.request(router: BoardRouter.inquireBoardListInCategory(categorySeq, page), type: InquireBoardListInCategoryResponse.self)
  }
  
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int) -> RxSwift.Single<InquireBoardDetailResponse> {
    service.request(router: BoardRouter.inquireBoardDetail(categorySeq, boardSeq), type: InquireBoardDetailResponse.self)
  }
  
  func createComment(request: CreateCommentRequest, categorySeq: Int, boardSeq: Int) -> RxSwift.Single<[Comment]> {
    service.request(router: BoardRouter.createComment(request, categorySeq, boardSeq), type: [Comment].self)
  }
  
  
}
