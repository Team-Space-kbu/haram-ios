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
  var boardComment: AnyObserver<String> { get }
  
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
}

final class BoardDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let boardType: BoardType
  private let boardSeq: Int
  
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  private let currentBoardInfoRelay = BehaviorRelay<[BoardDetailHeaderViewModel]>(value: [])
  
  private let createCommentSubject  = PublishSubject<String>()
  
  
  init(boardType: BoardType, boardSeq: Int) {
    self.boardType = boardType
    self.boardSeq = boardSeq
    inquireBoard()
  }
}

extension BoardDetailViewModel {
  
  /// 게시글에 대한 정보를 조회합니다
  private func inquireBoard() {
    let inquireBoard = BoardService.shared.inquireBoard(boardType: boardType, boardSeq: boardSeq)
    
    inquireBoard
      .subscribe(with: self) { owner, response in
        owner.currentBoardInfoRelay.accept([
          BoardDetailHeaderViewModel(
            boardTitle: response.boardTitle,
            boardContent: response.boardContent,
            boardDate: DateformatterFactory.dateWithHypen.date(from: response.createdAt) ?? Date(),
            boardAuthorName: "익명"
          )])
        
        owner.currentBoardListRelay.accept(response.commentDtoList.map { BoardDetailCollectionViewCellModel(commentDto: $0) })
      }
      .disposed(by: disposeBag)
  }
  
  /// 해당 게시글에 대한 댓글을 생성합니다
  private func createComment() {
    let createComment = createCommentSubject
      .withUnretained(self)
      .flatMapLatest {
        BoardService.shared.createComment(
          request: .init(
            boardSeq: $0.boardSeq,
            userID: UserManager.shared.userID!,
            commentContent: $1
          )
        )
      }
    
    createComment
      .subscribe(with: self) { owner, response in
        
      }
      .disposed(by: disposeBag)
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var boardComment: RxSwift.AnyObserver<String> {
    createCommentSubject.asObserver()
  }
  
  var boardInfoModel: RxCocoa.Driver<[BoardDetailHeaderViewModel]> {
    currentBoardInfoRelay.asDriver()
  }
  
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
}

