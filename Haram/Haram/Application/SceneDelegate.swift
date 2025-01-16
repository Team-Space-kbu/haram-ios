//
//  SceneDelegate.swift
//  Haram
//
//  Created by 이건준 on 2023/04/01.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var appCoordinator: AppCoordinator?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    let navigationController = UINavigationController()
    window = UIWindow(windowScene: scene)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    
    self.appCoordinator = AppCoordinator(navigationController: navigationController)
    appCoordinator?.start()
  }
}

