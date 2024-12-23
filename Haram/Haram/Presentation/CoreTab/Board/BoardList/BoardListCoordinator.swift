//
//  BoardListCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/25/24.
//

import UIKit

final class BoardListCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let title: String
  private let categorySeq: Int
  private let writeableBoard: Bool
  private let writeableAnonymous: Bool
  private let writeableComment: Bool
  
  init(
    title: String,
    categorySeq: Int,
    writeableBoard: Bool,
    writeableAnonymous: Bool,
    writeableComment: Bool,
    navigationController: UINavigationController
  ) {
    self.title = title
    self.categorySeq = categorySeq
    self.writeableBoard = writeableBoard
    self.writeableAnonymous = writeableAnonymous
    self.writeableComment = writeableComment
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BoardListViewController = BoardListViewController(
      viewModel: BoardListViewModel(
        payload: .init(
          categorySeq: categorySeq,
          writeableBoard: writeableBoard,
          writeableComment: writeableComment, 
          writeableAnonymous: writeableAnonymous
        ),
        dependency: .init(
          boardRepository: BoardRepositoryImpl(),
          coordinator: self
        )
      )
    )
    viewController.title = title
    viewController.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension BoardListCoordinator {
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
  
  func showEditBoardViewController(categorySeq: Int) {
    let vc = EditBoardViewController(categorySeq: categorySeq)
    vc.title = "게시글 작성"
    navigationController.pushViewController(vc, animated: true)
  }
  
  func showBoardDetailViewController(boardSeq: Int) {
    let coordinator = BoardDetailCoordinator(
      title: "게시판",
      categorySeq: categorySeq,
      boardSeq: boardSeq,
      writeableAnonymous: writeableAnonymous,
      writeableComment: writeableComment,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}

