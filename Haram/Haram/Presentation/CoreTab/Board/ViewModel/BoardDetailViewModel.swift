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
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int)
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int)
  
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
  var successCreateComment: Signal<(comment: String, createdAt: String)> { get }
}

final class BoardDetailViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  private let currentBoardInfoRelay = BehaviorRelay<[BoardDetailHeaderViewModel]>(value: [])
  private let successCreateCommentRelay = PublishRelay<(comment: String, createdAt: String)>()
  
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var successCreateComment: RxCocoa.Signal<(comment: String, createdAt: String)> {
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
          response.comments.map {
            BoardDetailCollectionViewCellModel(
              commentAuthorInfoModel: .init(
                commentAuthorName: $0.createdBy,
                commentDate: DateformatterFactory.iso8601.date(from: $0.createdAt) ?? Date()
              ),
              comment: $0.contents
            )
          }
        )
      }
      .disposed(by: disposeBag)
  }
  
  
  /// 해당 게시글에 대한 댓글을 생성합니다
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int) {
    
    boardRepository.createComment(
      request: .init(
        contents: boardComment,
        isAnonymous: true
      ),
      categorySeq: categorySeq,
      boardSeq: boardSeq
    )
      .subscribe(with: self) { owner, response in
        owner.successCreateCommentRelay.accept((
          comment: boardComment,
          createdAt: DateformatterFactory.dateWithHypen.string(from: Date())
        ))
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

