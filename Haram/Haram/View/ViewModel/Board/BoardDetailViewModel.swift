//
//  BoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/15/23.
//

import RxSwift
import RxCocoa

protocol BoardDetailViewModelType {
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
}

final class BoardDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let boardType: BoardType
  private let boardSeq: Int
  
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  private let currentBoardInfoRelay = BehaviorRelay<[BoardDetailHeaderViewModel]>(value: [])
  
  
  init(boardType: BoardType, boardSeq: Int) {
    self.boardType = boardType
    self.boardSeq = boardSeq
    inquireBoard()
  }
}

extension BoardDetailViewModel {
  
  private func inquireBoard() {
    let inquireBoard = BoardService.shared.inquireBoard(boardType: boardType, boardSeq: boardSeq)
    
    inquireBoard
      .subscribe(with: self) { owner, response in
        owner.currentBoardInfoRelay.accept([BoardDetailHeaderViewModel(
          authorInfoViewModel: .init(
            profileImageURL: nil,
            authorName: response.userID,
            postingDate: response.createdAt
          ),
          boardTitle: response.boardTitle,
          boardContent: response.boardContent)])
        
        owner.currentBoardListRelay.accept(response.commentDtoList.map { BoardDetailCollectionViewCellModel(commentDto: $0) })
      }
      .disposed(by: disposeBag)
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var boardInfoModel: RxCocoa.Driver<[BoardDetailHeaderViewModel]> {
    currentBoardInfoRelay.asDriver()
  }
  
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
}
