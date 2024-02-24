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
  var boardModel: Driver<[BoardTableViewCellModel]> { get }
}

final class BoardViewModel {
  
  private let disposeBag = DisposeBag()
  private let boardRepository: BoardRepository
  
  private let boardModelRelay = BehaviorRelay<[BoardTableViewCellModel]>(value: [])
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
    inquireBoardCategory()
  }
  
  private func inquireBoardCategory() {
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
      }
      .disposed(by: disposeBag)
  }
  
}

extension BoardViewModel: BoardViewModelType {
  var boardModel: RxCocoa.Driver<[BoardTableViewCellModel]> {
    boardModelRelay.asDriver()
  }
}
