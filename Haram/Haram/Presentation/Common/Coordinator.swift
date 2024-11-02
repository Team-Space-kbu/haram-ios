//
//  Coordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

import UIKit

protocol Coordinator: AnyObject {
  var navigationController: UINavigationController { get }
  var parentCoordinator: Coordinator? { get set }
  var childCoordinators: [Coordinator] { get set }
  func start()
}

extension Coordinator {
  func removeChildCoordinator(child: Coordinator) {
    childCoordinators.removeAll { $0 === child }
  }
}
