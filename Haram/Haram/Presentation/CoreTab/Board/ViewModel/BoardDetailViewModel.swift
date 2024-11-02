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
  func reportBoard(boardSeq: Int, reportType: ReportTitleType)
  func bannedUser(boardSeq: Int)
  func createComment(boardComment: String, categorySeq: Int, boardSeq: Int, isAnonymous: Bool)
  func inquireBoardDetail(categorySeq: Int, boardSeq: Int)
  func deleteBoard(categorySeq: Int, boardSeq: Int)
  func deleteComment(categorySeq: Int, boardSeq: Int, commentSeq: Int)
  
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
  var successCreateComment: Signal<[Comment]> { get }
  var errorMessage: Signal<HaramError> { get }
  var successReportBoard: Signal<Void> { get }
  var successDeleteboard: Signal<Void> { get }
  var successBannedboard: Signal<Void> { get }
}

final class BoardDetailViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = PublishRelay<[BoardDetailCollectionViewCellModel]>()
  private let currentBoardInfoRelay = PublishRelay<[BoardDetailHeaderViewModel]>()
  private let successCreateCommentRelay = PublishRelay<[Comment]>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  private let successReportBoardRelay = PublishRelay<Void>()
  private let successBannedBoardRelay = PublishRelay<Void>()
  private let successDeleteBoardRelay = PublishRelay<Void>()
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var successBannedboard: RxCocoa.Signal<Void> {
    successBannedBoardRelay.asSignal()
  }
  
  func bannedUser(boardSeq: Int) {
    boardRepository.bannedUser(boardSeq: boardSeq)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.successBannedBoardRelay.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var successDeleteboard: RxCocoa.Signal<Void> {
    successDeleteBoardRelay.asSignal()
  }
  
  func deleteBoard(categorySeq: Int, boardSeq: Int) {
    boardRepository.deleteBoard(categorySeq: categorySeq, boardSeq: boardSeq)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.successDeleteBoardRelay.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func deleteComment(categorySeq: Int, boardSeq: Int, commentSeq: Int) {
    boardRepository.deleteComment(categorySeq: categorySeq, boardSeq: boardSeq, commentSeq: commentSeq)
      .subscribe(with: self, onSuccess: { owner, comments in
        owner.currentBoardListRelay.accept(
          comments.enumerated()
            .map { index, comment in
            return BoardDetailCollectionViewCellModel(
              commentSeq: comment.seq, commentAuthorInfoModel: .init(
                commentAuthorName: comment.createdBy ?? "",
                commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: comment.createdAt) ?? Date(),
                isUpdatable: comment.isUpdatable
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
  
  var successReportBoard: RxCocoa.Signal<Void> {
    successReportBoardRelay.asSignal()
  }
  
  func reportBoard(boardSeq: Int, reportType: ReportTitleType) {
    boardRepository.reportBoard(
      request: .init(
        reportType: .board,
        refSeq: boardSeq,
        reportTitle: reportType,
        content: reportType.title
      )
    ).subscribe(with: self, onSuccess: { owner, _ in
        owner.successReportBoardRelay.accept(())
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error)
    })
    .disposed(by: disposeBag)
  }
  
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
            boardSeq: response.boardSeq, boardTitle: response.title,
            boardContent: response.contents,
            boardDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: response.createdAt) ?? Date(),
            boardAuthorName: response.createdBy,
            boardImageCollectionViewCellModel: response.files.map {
              BoardImageCollectionViewCellModel(imageURL: URL(string: $0.fileUrl))
            }, isUpdatable: response.isUpdatable)
        ])

        guard let comments = response.comments else {
          owner.currentBoardListRelay.accept([])
          return
        }
        owner.currentBoardListRelay.accept(
          comments.enumerated()
            .map { index, comment in
            return BoardDetailCollectionViewCellModel(
              commentSeq: comment.seq, commentAuthorInfoModel: .init(
                commentAuthorName: comment.createdBy ?? "",
                commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: comment.createdAt) ?? Date(),
                isUpdatable: comment.isUpdatable
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

