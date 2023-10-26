//
//  BoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/15/23.
//

import RxSwift
import RxCocoa

protocol BoardDetailViewModelType {
  var whichBoardType: AnyObserver<BoardType> { get }
  var whichBoardSeq: AnyObserver<Int> { get }
  
  var boardInfoModel: Driver<[BoardDetailHeaderViewModel]> { get }
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> { get }
}

final class BoardDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentBoardTypeRelay = PublishSubject<BoardType>()
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  private let currentBoardInfoRelay = BehaviorRelay<[BoardDetailHeaderViewModel]>(value: [])
  private let currentBoardSeq = PublishSubject<Int>()
  
  init() {
//    inquireBoardList()
    inquireBoard()
  }
}

extension BoardDetailViewModel {
  
  private func inquireBoard() {
    let inquireBoard = Observable.combineLatest(currentBoardTypeRelay, currentBoardSeq)
      .flatMapLatest(BoardService.shared.inquireBoard)
    
    let successInquireBoard = inquireBoard
      .compactMap { result -> InquireBoardResponse? in
        guard case let .success(response) = result else { return nil }
        return response
      }
    
    successInquireBoard
      .subscribe(with: self) { owner, response in
        owner.currentBoardInfoRelay.accept([BoardDetailHeaderViewModel(
          authorInfoViewModel: .init(
            profileImageURL: nil,
            authorName: response.userId,
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
  
  var whichBoardSeq: RxSwift.AnyObserver<Int> {
    currentBoardSeq.asObserver()
  }
  
  var whichBoardType: AnyObserver<BoardType> {
    currentBoardTypeRelay.asObserver()
  }
  
  var boardCommentModel: Driver<[BoardDetailCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
}
