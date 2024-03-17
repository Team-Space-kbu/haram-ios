//
//  BoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/23/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol BoardViewModelType {
  func inquireBoardCategory()
  var boardModel: Driver<[BoardTableViewCellModel]> { get }
  var boardHeaderTitle: Driver<String> { get }
}

final class BoardViewModel {
  
  private let disposeBag = DisposeBag()
  private let boardRepository: BoardRepository
  
  private let boardModelRelay = PublishRelay<[BoardTableViewCellModel]>()
  private let boardHeaderTitleRelay = PublishRelay<String>()
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  
  }
  
  func inquireBoardCategory() {
    boardRepository.inquireBoardCategory()
      .subscribe(with: self) { owner, response in
        owner.boardModelRelay.accept(response.map {
          BoardTableViewCellModel(
            categorySeq: $0.categorySeq,
            imageURL: URL(string: $0.iconUrl),
            title: $0.categoryName, 
            writeableBoard: $0.writeableBoard
          )
        })
        owner.boardHeaderTitleRelay.accept("학교 게시판")
      }
      .disposed(by: disposeBag)
  }
  
}

extension BoardViewModel: BoardViewModelType {
  var boardHeaderTitle: RxCocoa.Driver<String> {
    boardHeaderTitleRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var boardModel: RxCocoa.Driver<[BoardTableViewCellModel]> {
    boardModelRelay.asDriver(onErrorDriveWith: .empty())
  }
}
