//
//  BoardCoordinator.swift
//  Haram
//
//  Created by 이건준 on 11/8/24.
//

import UIKit

final class BoardCoordinator: NavigationCoordinator {
  var navigationController: UINavigationController
  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let viewController: BoardViewController = BoardViewController(
      viewModel: BoardViewModel(
        dependency: .init(
          boardRepository: BoardRepositoryImpl(),
          coordinator: self
        )
      )
    )
    self.navigationController.pushViewController(viewController, animated: true)
  }
}

extension BoardCoordinator {
  func showBoardListViewController(
    title: String,
    categorySeq: Int,
    writeableBoard: Bool,
    writeableAnonymous: Bool,
    writeableComment: Bool
  ) {
    let coordinator = BoardListCoordinator(
      title: title,
      categorySeq: categorySeq,
      writeableBoard: writeableBoard,
      writeableAnonymous: writeableAnonymous,
      writeableComment: writeableComment,
      navigationController: self.navigationController
    )
    coordinator.start()
    self.childCoordinators.append(coordinator)
  }
}
