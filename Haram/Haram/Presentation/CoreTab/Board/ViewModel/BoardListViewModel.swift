//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  
  func inquireBoardList()
  func refreshBoardList()
  var writeableBoard: Bool { get }
  var categorySeq: Int { get }
  var writeableComment: Bool { get }
  var writeableAnonymous: Bool { get }
  
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class BoardListViewModel {
  
  private let boardRepository: BoardRepository
  private let disposeBag = DisposeBag()
  let categorySeq: Int
  var writeableComment: Bool
  var writeableBoard: Bool
  var writeableAnonymous: Bool = true
  
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  private let errorMessageRelay     = BehaviorRelay<HaramError?>(value: nil)
  
  private var isLoading = false
  
  /// 요청한 페이지
  private var startPage = 1
  
  /// 마지막 페이지
  private var endPage = 2
  
  init(categorySeq: Int, writeableComment: Bool, writeableBoard: Bool, boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
    self.categorySeq = categorySeq
    self.writeableComment = writeableComment
    self.writeableBoard = writeableBoard
  }
}

extension BoardListViewModel: BoardListViewModelType {
  
  func inquireBoardList() {
    
    guard startPage <= endPage && !isLoading else { return }
    
    isLoading = true
    
    let inquireBoardList = boardRepository.inquireBoardListInCategory(categorySeq: categorySeq, page: startPage)
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        var currentBoardList = owner.currentBoardListRelay.value
        let categoryName = response.categoryName
        let addBoardList = response.boards.map {
          BoardListCollectionViewCellModel(
            boardSeq: $0.boardSeq,
            title: $0.title,
            subTitle: $0.contents,
            boardType: [categoryName]
          )
        }
        currentBoardList.append(contentsOf: addBoardList)
        
        owner.writeableAnonymous = response.writeableAnonymous
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
  
  func refreshBoardList() {
    
    isLoading = true
    
    let inquireBoardList = boardRepository.inquireBoardListInCategory(categorySeq: categorySeq, page: 1)
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        var currentBoardList = owner.currentBoardListRelay.value
        let categoryName = response.categoryName
        let addBoardList = response.boards.map {
          BoardListCollectionViewCellModel(
            boardSeq: $0.boardSeq,
            title: $0.title,
            subTitle: $0.contents,
            boardType: [categoryName]
          )
        }
        currentBoardList.append(contentsOf: addBoardList)
        
        owner.writeableAnonymous = response.writeableAnonymous
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
