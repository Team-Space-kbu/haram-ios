//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import Foundation

import RxSwift
import RxCocoa

final class BoardListViewModel: ViewModelType {
  
  private let dependency: Dependency
  private let payload: Payload
  private let disposeBag = DisposeBag()
  
  private var isLoading = false
  
  /// 요청한 페이지
  private var startPage = 1
  
  /// 마지막 페이지
  private var endPage = 2
  
  struct Payload {
    let categorySeq: Int
    let writeableBoard: Bool
    let writeableComment: Bool
    let writeableAnonymous: Bool
  }
  
  struct Dependency {
    let boardRepository: BoardRepository
    let coordinator: BoardListCoordinator
  }
  
  struct Input {
    let viewWillAppear: Observable<Void>
    let didTapBoardListCell: Observable<IndexPath>
    let didTapBackButton: Observable<Void>
    let didTapEditButton: Observable<Void>
    let didScrollToBottom: Observable<Void>
  }
  
  struct Output {
    let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
    let errorMessageRelay     = PublishRelay<HaramError>()
    let writeableBoard        = PublishRelay<Bool>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewWillAppear
      .subscribe(with: self) { owner, _ in
        owner.refreshBoardList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didScrollToBottom
      .subscribe(with: self) { owner, _ in
        owner.inquireBoardList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapBoardListCell
      .withLatestFrom(output.currentBoardListRelay) { $1[$0.row] }
      .subscribe(with: self) { owner, boardModel in
        owner.dependency.coordinator.showBoardDetailViewController(boardSeq: boardModel.boardSeq)
      }
      .disposed(by: disposeBag)
    
    input.didTapEditButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showEditBoardViewController(categorySeq: owner.payload.categorySeq)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension BoardListViewModel {
  func inquireBoardList(output: Output) {
    guard startPage <= endPage && !isLoading else { return }
    
    isLoading = true
    
    let inquireBoardList = dependency.boardRepository.inquireBoardListInCategory(
      categorySeq: payload.categorySeq,
      page: startPage
    )
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        var currentBoardList = output.currentBoardListRelay.value
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
        output.writeableBoard.accept(response.writeableBoard)
        output.currentBoardListRelay.accept(currentBoardList)
        
        // 다음 페이지 요청을 위해 +1
        owner.startPage = response.startPage + 1
        owner.endPage = response.endPage
        owner.isLoading = false
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
        owner.isLoading = false
      })
      .disposed(by: disposeBag)
  }
  
  func refreshBoardList(output: Output) {
    isLoading = true
    
    let inquireBoardList = dependency.boardRepository.inquireBoardListInCategory(
      categorySeq: payload.categorySeq,
      page: 1
    )
    
    inquireBoardList
      .subscribe(with: self, onSuccess: { owner, response in
        let categoryName = response.categoryName
        let addBoardList = response.boards.map {
          BoardListCollectionViewCellModel(
            boardSeq: $0.boardSeq,
            title: $0.title,
            subTitle: $0.contents,
            boardType: [categoryName]
          )
        }
        output.currentBoardListRelay.accept(addBoardList)
        output.writeableBoard.accept(response.writeableBoard)
        owner.isLoading = false
        
        // 다음 페이지 요청을 위해 +1
        owner.startPage = response.startPage + 1
        owner.endPage = response.endPage
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
        owner.isLoading = false
      })
      .disposed(by: disposeBag)
  }
}
