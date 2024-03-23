//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  
  func inquireBoardList(categorySeq: Int)
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var writeableAnonymous: Signal<Bool> { get }
}

final class BoardListViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  private let isLoadingSubject      = PublishSubject<Bool>()
  private let errorMessageRelay     = BehaviorRelay<HaramError?>(value: nil)
  private let writeableAnonymousSubject = PublishSubject<Bool>()
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var writeableAnonymous: RxCocoa.Signal<Bool> {
    writeableAnonymousSubject.asSignal(onErrorSignalWith: .empty())
  }
  
  func inquireBoardList(categorySeq: Int) {
    let inquireBoardList = boardRepository.inquireBoardListInCategory(categorySeq: categorySeq)
    
    inquireBoardList
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
      .subscribe(with: self, onSuccess: { owner, response in
        let boardList = response.boards.map { BoardListCollectionViewCellModel(board: $0) }
        owner.writeableAnonymousSubject.onNext(response.writeableAnonymous)
        owner.currentBoardListRelay.accept(boardList)
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
//        owner.isLoadingSubject.onNext(false)
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
}
