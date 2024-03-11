//
//  BoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/15/23.
//

import RxSwift
import RxCocoa
import Foundation

protocol BoardDetailViewModelType {
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int, isAnonymous: Bool)
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int)
  
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
  var successCreateComment: Signal<[Comment]> { get }
}

final class BoardDetailViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  private let currentBoardInfoRelay = BehaviorRelay<[BoardDetailHeaderViewModel]>(value: [])
  private let successCreateCommentRelay = PublishRelay<[Comment]>()
  
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var successCreateComment: RxCocoa.Signal<[Comment]> {
    successCreateCommentRelay.asSignal()
  }
  
  
  /// 게시글에 대한 정보를 조회합니다
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int) {
    let inquireBoard = boardRepository.inquireBoardDetail(
      categorySeq: categorySeq,
      boardSeq: boardSeq
    )
    
    inquireBoard
      .subscribe(with: self) { owner, response in
        owner.currentBoardInfoRelay.accept([
          BoardDetailHeaderViewModel(
            boardTitle: response.title,
            boardContent: response.contents,
            boardDate: DateformatterFactory.iso8601.date(from: response.createdAt) ?? Date(),
            boardAuthorName: response.createdBy,
            boardImageCollectionViewCellModel: response.files.map {
              BoardImageCollectionViewCellModel(imageURL: URL(string: $0.fileUrl))
            })
        ])

        owner.currentBoardListRelay.accept(
          response.comments.enumerated()
            .map { index, comment in
            return BoardDetailCollectionViewCellModel(
              commentAuthorInfoModel: .init(
                commentAuthorName: comment.createdBy,
                commentDate: DateformatterFactory.iso8601.date(from: comment.createdAt) ?? Date()
              ),
              comment: comment.contents, isLastComment: response.comments.count - 1 == index ? true : false
            )
          }
        )
      }
      .disposed(by: disposeBag)
  }
  
  
  /// 해당 게시글에 대한 댓글을 생성합니다
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int, isAnonymous: Bool) {
    
    boardRepository.createComment(
      request: .init(
        contents: boardComment,
        isAnonymous: isAnonymous
      ),
      categorySeq: categorySeq,
      boardSeq: boardSeq
    )
      .subscribe(with: self) { owner, response in
        owner.successCreateCommentRelay.accept(response)
      }
      .disposed(by: disposeBag)
  }
  
  var boardInfoModel: RxCocoa.Driver<[BoardDetailHeaderViewModel]> {
    currentBoardInfoRelay.asDriver()
  }
  
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
}

