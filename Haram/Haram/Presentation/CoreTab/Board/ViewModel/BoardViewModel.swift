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
  var errorMessage: Signal<HaramError> { get }
  var headerTitle: String { get }
}

final class BoardViewModel {
  
  private let disposeBag = DisposeBag()
  private let boardRepository: BoardRepository
  
  private var isFetched: Bool = false
  private let boardModelRelay = PublishRelay<[BoardTableViewCellModel]>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  var headerTitle: String = "학교 게시판"
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl()) {
    self.boardRepository = boardRepository
  }
  
  func inquireBoardCategory() {
    
    guard !isFetched else { return }
    
    boardRepository.inquireBoardCategory()
      .subscribe(with: self, onSuccess: { owner, response in
        owner.boardModelRelay.accept(response.map {
          BoardTableViewCellModel(
            categorySeq: $0.categorySeq,
            imageURL: URL(string: $0.iconUrl),
            title: $0.categoryName,
            writeableBoard: $0.writeableBoard, 
            writeableComment: $0.writeableComment
          )
        })
        owner.isFetched = true
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
}

extension BoardViewModel: BoardViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.distinctUntilChanged().asSignal(onErrorSignalWith: .empty())
  }
  
  var boardModel: RxCocoa.Driver<[BoardTableViewCellModel]> {
    boardModelRelay.asDriver(onErrorDriveWith: .empty())
  }
}
