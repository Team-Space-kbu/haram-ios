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
  var errorMessage: Signal<HaramError> { get }
}

final class BoardDetailViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = PublishRelay<[BoardDetailCollectionViewCellModel]>()
  private let currentBoardInfoRelay = PublishRelay<[BoardDetailHeaderViewModel]>()
  private let successCreateCommentRelay = PublishRelay<[Comment]>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
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
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentBoardInfoRelay.accept([
          BoardDetailHeaderViewModel(
            boardTitle: response.title,
            boardContent: response.contents,
            boardDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: response.createdAt) ?? Date(),
            boardAuthorName: response.createdBy,
            boardImageCollectionViewCellModel: response.files.map {
              BoardImageCollectionViewCellModel(imageURL: URL(string: $0.fileUrl))
            })
        ])

        guard let comments = response.comments else {
          owner.currentBoardListRelay.accept([])
          return
        }
        owner.currentBoardListRelay.accept(
          comments.enumerated()
            .map { index, comment in
            return BoardDetailCollectionViewCellModel(
              commentAuthorInfoModel: .init(
                commentAuthorName: comment.createdBy,
                commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: comment.createdAt) ?? Date()
              ),
              comment: comment.contents, isLastComment: comments.count - 1 == index ? true : false
            )
          }
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  
  /// 해당 게시글에 대한 댓글을 생성합니다
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int, isAnonymous: Bool) {
    guard !boardComment.isEmpty else { return }
    boardRepository.createComment(
      request: .init(
        contents: boardComment,
        isAnonymous: isAnonymous
      ),
      categorySeq: categorySeq,
      boardSeq: boardSeq
    )
      .subscribe(with: self, onSuccess: { owner, response in
        owner.successCreateCommentRelay.accept(response)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error == .networkError ? .retryError : error)
      })
      .disposed(by: disposeBag)
  }
  
  var boardInfoModel: RxCocoa.Driver<[BoardDetailHeaderViewModel]> {
    currentBoardInfoRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> {
    currentBoardListRelay.asDriver(onErrorDriveWith: .empty())
  }
}

