//
//  EmptyClassCoordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

//import UIKit
//
//final class EmptyClassCoordinator: Coordinator {
//  var navigationController: UINavigationController
//  var parentCoordinator: Coordinator?
//  var childCoordinators: [Coordinator] = []
//  
//  init(navigationController: UINavigationController) {
//      self.navigationController = navigationController
//  }
//  
//  func start() {
//    let viewController: EmptyClassViewController = EmptyClassViewController(viewModel: EmptyClassViewModel(coordinator: self))
//    self.navigationController.pushViewController(viewController, animated: true)
//  }
//  
//  func goToCourseListViewController(type: ClassType) {
//    print("빈 강의실 셀 선택")
//  }
//}
