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
    let viewWillAppear: Observable<Void>
    let didTapBoardCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let boardModel = PublishRelay<[BoardTableViewCellModel]>()
    let boardHeaderTitle = PublishRelay<String>()
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewWillAppear
      .subscribe(with: self) { owner, _ in
        owner.inquireBoardCategory(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBoardCell
      .withLatestFrom(output.boardModel) { $1[$0.row] }
      .subscribe(with: self) { owner, boardModel in
        owner.dependency.coordinator.showBoardListViewController(
          title: boardModel.title,
          categorySeq: boardModel.categorySeq,
          writeableBoard: boardModel.writeableBoard,
          writeableAnonymous: boardModel.writeableAnonymous,
          writeableComment: boardModel.writeableComment
        )
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireBoardCategory(output: output)
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
        output.boardModel.accept(response.map {
          BoardTableViewCellModel(
            categorySeq: $0.categorySeq,
            imageURL: URL(string: $0.iconUrl),
            title: $0.categoryName,
            writeableBoard: $0.writeableBoard,
            writeableComment: $0.writeableComment,
            writeableAnonymous: $0.writeableAnonymous
          )
        })
        output.boardHeaderTitle.accept("학교 게시판")
        owner.isFetched = true
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
