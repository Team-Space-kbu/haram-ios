//
//  BoardDetailCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/26/24.
//

import UIKit

final class BoardDetailCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  private let title: String
  private let categorySeq: Int
  private let boardSeq: Int
  private let writeableAnonymous: Bool
  private let writeableComment: Bool
  
  init(
    title: String,
    categorySeq: Int,
    boardSeq: Int,
    writeableAnonymous: Bool,
    writeableComment: Bool,
    navigationController: UINavigationController
  ) {
    self.title = title
    self.categorySeq = categorySeq
    self.boardSeq = boardSeq
    self.writeableAnonymous = writeableAnonymous
    self.writeableComment = writeableComment
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BoardDetailViewController = BoardDetailViewController(
      viewModel: BoardDetailViewModel(
        payload: .init(
          boardSeq: boardSeq,
          categorySeq: categorySeq,
          writeableAnonymous: writeableAnonymous,
          writeableComment: writeableComment
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

extension BoardDetailCoordinator {
  func showAlert(title: String = "Space 알림", message: String, confirmHandler: (() -> Void)? = nil) {
    AlertManager.showAlert(on: self.navigationController, message: .custom(message), confirmHandler: confirmHandler)
  }
  
  func popViewController() {
    self.parentCoordinator?.removeChildCoordinator(child: self)
    self.navigationController.popViewController(animated: true)
  }
}
