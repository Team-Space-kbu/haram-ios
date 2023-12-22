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
  var isLoading: Driver<Bool> { get }
}

final class BoardListViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let boardType: BoardType
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  private let isLoadingSubject      = PublishSubject<Bool>()
  
  init(boardType: BoardType) {
    self.boardType = boardType
    inquireBoardList()
  }
}

extension BoardListViewModel {
  private func inquireBoardList() {
    let inquireBoardList = BoardService.shared.inquireBoardlist(boardType: boardType)
    
    inquireBoardList
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .map { $0.map { BoardListCollectionViewCellModel(response: $0) } }
      .subscribe(with: self, onSuccess: { owner, model in
        owner.currentBoardListRelay.accept(model)
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError,
              error == .noExistBoard else { return }
        owner.isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
