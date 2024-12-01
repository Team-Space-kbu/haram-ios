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
  var errorMessage: Signal<HaramError> { get }
}

final class BoardViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private var isFetched: Bool = false
  
  struct Payload {
    
  }
  
  struct Dependency {
    let boardRepository: BoardRepository
    let coordinator: BoardCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBoardCell: Observable<IndexPath>
  }
  
  struct Output {
    let boardModelRelay = PublishRelay<[BoardTableViewCellModel]>()
    let boardHeaderTitleRelay = PublishRelay<String>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireBoardCategory(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBoardCell
      .withLatestFrom(output.boardModelRelay) { $1[$0.row] }
      .subscribe(with: self) { owner, boardModel in
        print("야 \(boardModel)")
        owner.dependency.coordinator.showBoardListViewController(
          title: boardModel.title,
          categorySeq: boardModel.categorySeq,
          writeableBoard: boardModel.writeableBoard,
          writeableAnonymous: boardModel.writeableAnonymous,
          writeableComment: boardModel.writeableComment
        )
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension BoardViewModel {
  func inquireBoardCategory(output: Output) {
    
    guard !isFetched else { return }
    
    dependency.boardRepository.inquireBoardCategory()
      .subscribe(with: self, onSuccess: { owner, response in
        output.boardModelRelay.accept(response.map {
          BoardTableViewCellModel(
            categorySeq: $0.categorySeq,
            imageURL: URL(string: $0.iconUrl),
            title: $0.categoryName,
            writeableBoard: $0.writeableBoard,
            writeableComment: $0.writeableComment,
            writeableAnonymous: $0.writeableAnonymous
          )
        })
        output.boardHeaderTitleRelay.accept("학교 게시판")
        owner.isFetched = true
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
//  var errorMessage: RxCocoa.Signal<HaramError> {
//    errorMessageRelay.compactMap { $0 }.distinctUntilChanged().asSignal(onErrorSignalWith: .empty())
//  }
//  
//  var boardHeaderTitle: RxCocoa.Driver<String> {
//    boardHeaderTitleRelay.asDriver(onErrorDriveWith: .empty())
//  }
//  
//  var boardModel: RxCocoa.Driver<[BoardTableViewCellModel]> {
//    boardModelRelay.asDriver(onErrorDriveWith: .empty())
//  }
}
