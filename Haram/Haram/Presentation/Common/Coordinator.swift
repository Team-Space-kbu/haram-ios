//
//  Coordinator.swift
//  Haram
//
//  Created by 이건준 on 10/8/24.
//

import UIKit

protocol Coordinator: AnyObject {
  var parentCoordinator: Coordinator? { get set }
  var childCoordinators: [Coordinator] { get set }
  func start()
}

extension Coordinator {
  func removeChildCoordinator(child: Coordinator) {
    childCoordinators.removeAll { $0 === child }
  }
}

/// UINavigation에 속한 ViewController에서 사용할 Coordinator
protocol NavigationCoordinator: Coordinator {
  var navigationController: UINavigationController { get }
}

//extension NavigationCoordinator {
//  func showAlert(message: String, actions: [AlertButtonType] = [.confirm()], confirmHandler: (() -> Void)? = nil) {
//    AlertManager.showAlert(
//      on: self.navigationController,
//      message: .custom(message),
//      actions: actions,
//      confirmHandler: confirmHandler
//    )
//  }
//  
//  func openSettings() {
//    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
//    if UIApplication.shared.canOpenURL(url) {
//      UIApplication.shared.open(url)
//    }
//  }
//}
