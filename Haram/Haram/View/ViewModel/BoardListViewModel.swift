//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
}

final class BoardListViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let boardType: BoardType
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  
  init(boardType: BoardType) {
    self.boardType = boardType
    inquireBoardList()
  }
}

extension BoardListViewModel {
  private func inquireBoardList() {
    let inquireBoardList = BoardService.shared.inquireBoardlist(boardType: boardType)
    
    inquireBoardList
      .map { $0.map { BoardListCollectionViewCellModel(response: $0) } }
      .subscribe(with: self) { owner, model in
        owner.currentBoardListRelay.accept(model)
      }
      .disposed(by: disposeBag)
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
}
