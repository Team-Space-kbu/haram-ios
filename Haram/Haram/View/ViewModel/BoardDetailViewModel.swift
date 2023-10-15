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
}

final class BoardDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentBoardTypeRelay = PublishSubject<BoardType>()
  private let currentBoardListRelay = BehaviorRelay<[BoardDetailCollectionViewCellModel]>(value: [])
  
  init() {
    inquireBoardList()
  }
}

extension BoardDetailViewModel {
  private func inquireBoardList() {
    let inquireBoardList = currentBoardTypeRelay
      .flatMapLatest(BoardService.shared.inquireBoardlist(boardType: ))
    
    let inquireBoardListToResponse = inquireBoardList
      .compactMap { result -> [InquireBoardlistResponse]? in
        guard case .success(let response) = result else { return nil }
        return response
      }
    
    inquireBoardListToResponse
      .subscribe(with: self) { owner, response in
        
      }
      .disposed(by: disposeBag)
  }
}

extension BoardDetailViewModel: BoardDetailViewModelType {
  var whichBoardType: AnyObserver<BoardType> {
    currentBoardTypeRelay.asObserver()
  }
}
