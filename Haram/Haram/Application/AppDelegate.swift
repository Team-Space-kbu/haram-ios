//
//  AppDelegate.swift
//  Haram
//
//  Created by 이건준 on 2023/04/01.
//

import UIKit
import CoreData

import Firebase
import NMapsMap
import SkeletonView
import SDWebImageSVGCoder


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: - CoreData
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "RevisionOfTranslation") // 여기는 파일명을 적어줘요.
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error {
        fatalError("Unresolved error, \((error as NSError).userInfo)")
      }
    })
    return container
  }()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    NetworkManager.shared.startMonitoring()
    NMFAuthManager.shared().clientId = NaverMapKeyConstants.clientID
    
    FirebaseApp.configure()
    SkeletonAppearance.default.textLineHeight = .relativeToFont
    
    if !UserManager.shared.hasUUID {
      UserManager.shared.set(uuid: UUID().uuidString)
    }
    
    setupNavigationBarStyle()
    setupSDImageSVGCoder()
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}

extension AppDelegate {
  private func setupSDImageSVGCoder() {
    let SVGCoder = SDImageSVGCoder.shared
    SDImageCodersManager.shared.addCoder(SVGCoder)
  }
  
  private func setupNavigationBarStyle() {
    let appearance = UINavigationBarAppearance()
    
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    
    appearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black,
      NSAttributedString.Key.font: UIFont.bold20
    ]
    
    // 내비바 하단 회색선 제거
    appearance.shadowColor = .clear
    appearance.shadowImage = UIImage()
    
    let scrollEdgeAppearance = UINavigationBarAppearance()
    scrollEdgeAppearance.backgroundColor = .white
    scrollEdgeAppearance.configureWithOpaqueBackground()
    scrollEdgeAppearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black,
      NSAttributedString.Key.font: UIFont.bold20
    ]
    scrollEdgeAppearance.shadowImage = UIImage()
    
    
    UINavigationBar.appearance().tintColor = .black
    UINavigationBar.appearance().standardAppearance = scrollEdgeAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}
