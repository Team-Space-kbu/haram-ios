//
//  Coordinator.swift
//  Haram
//
//  Created by 이건준 on 1/3/24.
//

import UIKit

protocol Coordinator {
  var parentCoordinator: Coordinator? { get set }
  var children: [Coordinator] { get set }
  
  var navigationController: UINavigationController { get set }
  func start()
}

final class HomeCoordinator: Coordinator {
  var parentCoordinator: Coordinator?
  
  var children: [Coordinator] = []
  
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let homeViewController = HomeViewController().then {
      $0.tabBarItem = UITabBarItem(
        title: "하람",
        image: UIImage(named: "home"),
        tag: 0
      )
    }
    homeViewController.coordinator = self
    navigationController.pushViewController(homeViewController, animated: true)
  }
  
  func didTappedShortcut(type: ShortcutType) {
    let vc = type.viewController
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didTappedNews(newsModel: HomeNewsCollectionViewCellModel) {
    let vc = PDFViewController(pdfURL: newsModel.pdfURL)
    vc.title = newsModel.title
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(vc, animated: true)
  }
  
}

final class BoardCoordinator: Coordinator {
  var parentCoordinator: Coordinator?
  
  var children: [Coordinator] = []
  
  var navigationController: UINavigationController
  
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let boardViewController = BoardViewController().then {
      $0.tabBarItem = UITabBarItem(
        title: "게시판",
        image: UIImage(named: "board"),
        tag: 2
      )
    }
    boardViewController.coordinator = self
    navigationController.pushViewController(boardViewController, animated: true)
  }
  
  func didTappedBoardList(type: BoardType) {
    let vc = BoardListViewController(type: type)
    vc.title = "게시판"
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(vc, animated: true)
  }
  
}
final class MoreCoordinator: Coordinator {
  
  var parentCoordinator: Coordinator?
  
  var children: [Coordinator] = []
  
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let moreViewController = MoreViewController().then {
      $0.tabBarItem = UITabBarItem(
        title: "더보기",
        image: UIImage(named: "more"),
        tag: 3
      )
    }
    // HomeViewController에 대한 설정 및 필요한 작업 수행
    navigationController.pushViewController(moreViewController, animated: true)
  }
  
}

final class LibraryCoordinator: Coordinator {
  var parentCoordinator: Coordinator?
  
  var children: [Coordinator] = []
  
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    
  }
  
  
}
