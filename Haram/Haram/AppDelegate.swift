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
    // Override point for customization after application launch.
    setupNavigationBarStyle()
//    FirebaseApp.configure()
    
    // Initialize RevisionOfTranslation
    let models = CoreDataManager.shared.getRevisionOfTranslation()
    if models.isEmpty {
      CoreDataManager.shared.saveRevisionOfTranslations(models: [
        .init(bibleName: "창세기", chapter: 50, jeol: 1533, id: 1),
        .init(bibleName: "출애굽기", chapter: 40, jeol: 1213, id: 2),
        .init(bibleName: "레위기", chapter: 27, jeol: 859, id: 3),
        .init(bibleName: "민수기", chapter: 36, jeol: 1288, id: 4),
        .init(bibleName: "신명기", chapter: 34, jeol: 959, id: 5),
        .init(bibleName: "여호수아", chapter: 24, jeol: 658, id: 6),
        .init(bibleName: "사사기", chapter: 21, jeol: 618, id: 7),
        .init(bibleName: "룻기", chapter: 4, jeol: 85, id: 8),
        .init(bibleName: "사무엘상", chapter: 31, jeol: 810, id: 9),
        .init(bibleName: "사무엘하", chapter: 24, jeol: 695, id: 10),
        .init(bibleName: "열왕기상", chapter: 22, jeol: 816, id: 11),
        .init(bibleName: "열왕기하", chapter: 25, jeol: 719, id: 12),
        .init(bibleName: "역대상", chapter: 29, jeol: 942, id: 13),
        .init(bibleName: "역대하", chapter: 36, jeol: 822, id: 14),
        .init(bibleName: "에스라", chapter: 10, jeol: 280, id: 15),
        .init(bibleName: "느헤미야", chapter: 13, jeol: 406, id: 16),
        .init(bibleName: "에스더", chapter: 10, jeol: 167, id: 17),
        .init(bibleName: "욥기", chapter: 42, jeol: 1070, id: 18),
        .init(bibleName: "시편", chapter: 150, jeol: 2461, id: 19),
        .init(bibleName: "잠언", chapter: 31, jeol: 915, id: 20),
        .init(bibleName: "전도서", chapter: 12, jeol: 222, id: 21),
        .init(bibleName: "아가", chapter: 8, jeol: 117, id: 22),
        .init(bibleName: "이사야", chapter: 66, jeol: 1292, id: 23),
        .init(bibleName: "예레미야", chapter: 52, jeol: 1364, id: 24),
        .init(bibleName: "에레미야 애가", chapter: 5, jeol: 154, id: 25),
        .init(bibleName: "에스겔", chapter: 48, jeol: 1273, id: 26),
        .init(bibleName: "다니엘", chapter: 12, jeol: 357, id: 27),
        .init(bibleName: "호세아", chapter: 14, jeol: 197, id: 28),
        .init(bibleName: "요엘", chapter: 3, jeol: 73, id: 29),
        .init(bibleName: "아모스", chapter: 9, jeol: 146, id: 30),
        .init(bibleName: "오바댜", chapter: 1, jeol: 21, id: 31),
        .init(bibleName: "요나", chapter: 4, jeol: 48, id: 32),
        .init(bibleName: "미가", chapter: 7, jeol: 105, id: 33),
        .init(bibleName: "나훔", chapter: 3, jeol: 47, id: 34),
        .init(bibleName: "하박국", chapter: 3, jeol: 56, id: 35),
        .init(bibleName: "스바냐", chapter: 3, jeol: 53, id: 36),
        .init(bibleName: "학개", chapter: 2, jeol: 38, id: 37),
        .init(bibleName: "스가랴", chapter: 14, jeol: 211, id: 38),
        .init(bibleName: "말라기", chapter: 4, jeol: 55, id: 39),
        .init(bibleName: "마태복음", chapter: 28, jeol: 1071, id: 40),
        .init(bibleName: "마가복음", chapter: 16, jeol: 678, id: 41),
        .init(bibleName: "누가복음", chapter: 24, jeol: 1151, id: 42),
        .init(bibleName: "요한복음", chapter: 21, jeol: 879, id: 43),
        .init(bibleName: "사도행전", chapter: 28, jeol: 1007, id: 44),
        .init(bibleName: "로마서", chapter: 16, jeol: 433, id: 45),
        .init(bibleName: "고린도전서", chapter: 16, jeol: 437, id: 46),
        .init(bibleName: "고린도후서", chapter: 13, jeol: 257, id: 47),
        .init(bibleName: "갈라디아서", chapter: 6, jeol: 149, id: 48),
        .init(bibleName: "에베소서", chapter: 6, jeol: 155, id: 49),
        .init(bibleName: "빌립보서", chapter: 4, jeol: 104, id: 50),
        .init(bibleName: "골로새서", chapter: 4, jeol: 95, id: 51),
        .init(bibleName: "데살로니가전서", chapter: 5, jeol: 89, id: 52),
        .init(bibleName: "데살로니가후서", chapter: 3, jeol: 47, id: 53),
        .init(bibleName: "디모데전서", chapter: 6, jeol: 113, id: 54),
        .init(bibleName: "디모데후서", chapter: 4, jeol: 83, id: 55),
        .init(bibleName: "디도서", chapter: 3, jeol: 46, id: 56),
        .init(bibleName: "빌레몬서", chapter: 1, jeol: 25, id: 57),
        .init(bibleName: "히브리서", chapter: 13, jeol: 303, id: 58),
        .init(bibleName: "야고보서", chapter: 5, jeol: 108, id: 59),
        .init(bibleName: "베드로전서", chapter: 5, jeol: 105, id: 60),
        .init(bibleName: "베드로후서", chapter: 3, jeol: 61, id: 61),
        .init(bibleName: "요한일서", chapter: 5, jeol: 105, id: 62),
        .init(bibleName: "요한이서", chapter: 1, jeol: 13, id: 63),
        .init(bibleName: "요한삼서", chapter: 1, jeol: 14, id: 64),
        .init(bibleName: "유다서", chapter: 1, jeol: 25, id: 65),
        .init(bibleName: "요한계시록", chapter: 22, jeol: 404, id: 66),
      ]) { success in
        LogHelper.log("개역개정 초기 데이터 세팅: \(success)", level: .debug)
      }
    }
    
    // Set NaverMaps ClientID
    NMFAuthManager.shared().clientId = NaverMapKeyConstants.clientID
    
    SkeletonAppearance.default.textLineHeight = .relativeToFont
    
    // Set UUID
    if !UserManager.shared.hasUUID {
      UserManager.shared.set(uuid: UUID().uuidString)
    }
    
    // Set 이미지 SVG파일 UIImageView 파싱을 위함
    let SVGCoder = SDImageSVGCoder.shared
    SDImageCodersManager.shared.addCoder(SVGCoder)
    
    // Set Network Status
    NetworkManager.shared.startMonitoring()
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  private func setupNavigationBarStyle() {
    let appearance = UINavigationBarAppearance()
    
    appearance.configureWithOpaqueBackground() // 반투명 색상
    appearance.backgroundColor = .white // 배경색
    
    appearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black, // 텍스트 색상
      NSAttributedString.Key.font: UIFont.bold20 // 폰트
    ]
    
    // 내비바 하단 회색선 제거
    appearance.shadowColor = .clear
    appearance.shadowImage = UIImage()
    
    let scrollEdgeAppearance = UINavigationBarAppearance()
    scrollEdgeAppearance.backgroundColor = .white
    scrollEdgeAppearance.configureWithOpaqueBackground()
    scrollEdgeAppearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black, // 텍스트 색상
      NSAttributedString.Key.font: UIFont.bold20 // 폰트
    ]
    // 내비바 하단 회색선 제거
    //    scrollEdgeAppearance.shadowColor = .lightGray
    scrollEdgeAppearance.shadowImage = UIImage()
    
    
    UINavigationBar.appearance().tintColor = .black
    UINavigationBar.appearance().standardAppearance = scrollEdgeAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}

