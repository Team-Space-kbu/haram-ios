//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  
  func inquireBoardList(boardType: BoardType)
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class BoardListViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  private let isLoadingSubject      = PublishSubject<Bool>()
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardListViewModel: BoardListViewModelType {
  func inquireBoardList(boardType: BoardType) {
    let inquireBoardList = boardRepository.inquireBoardlist(boardType: boardType)
    
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
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
