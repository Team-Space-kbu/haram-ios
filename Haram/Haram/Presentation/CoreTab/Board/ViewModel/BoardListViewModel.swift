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
  func refreshBoardList(categorySeq: Int)
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
  var errorMessage: Signal<HaramError> { get }
  var writeableAnonymous: Signal<Bool> { get }
}

final class BoardListViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  private let errorMessageRelay     = BehaviorRelay<HaramError?>(value: nil)
  private let writeableAnonymousSubject = PublishSubject<Bool>()
  
  private var isLoading = false
  
  /// 요청한 페이지
  private var startPage = 1
  
  /// 마지막 페이지
  private var endPage = 2
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var writeableAnonymous: RxCocoa.Signal<Bool> {
    writeableAnonymousSubject.asSignal(onErrorSignalWith: .empty())
  }
  
  func inquireBoardList(categorySeq: Int) {
    
    guard startPage <= endPage && !isLoading else { return }
    
    isLoading = true
    
    let inquireBoardList = boardRepository.inquireBoardListInCategory(categorySeq: categorySeq, page: startPage)
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        var currentBoardList = owner.currentBoardListRelay.value
        let addBoardList = response.boards.map { BoardListCollectionViewCellModel(board: $0) }
        currentBoardList.append(contentsOf: addBoardList)
        
        owner.writeableAnonymousSubject.onNext(response.writeableAnonymous)
        owner.currentBoardListRelay.accept(currentBoardList)
        owner.isLoading = false
        
        // 다음 페이지 요청을 위해 +1
        owner.startPage = response.startPage + 1
        owner.endPage = response.endPage
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
        owner.isLoading = false
      })
      .disposed(by: disposeBag)
  }
  
  func refreshBoardList(categorySeq: Int) {
    
    isLoading = true
    
    let inquireBoardList = boardRepository.inquireBoardListInCategory(categorySeq: categorySeq, page: 1)
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        var currentBoardList = owner.currentBoardListRelay.value
        let addBoardList = response.boards.map { BoardListCollectionViewCellModel(board: $0) }
        currentBoardList.append(contentsOf: addBoardList)
        
        owner.writeableAnonymousSubject.onNext(response.writeableAnonymous)
        owner.currentBoardListRelay.accept(addBoardList)
        owner.isLoading = false
        
        // 다음 페이지 요청을 위해 +1
        owner.startPage = response.startPage + 1
        owner.endPage = response.endPage
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
        owner.isLoading = false
      })
      .disposed(by: disposeBag)
  }
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
}
