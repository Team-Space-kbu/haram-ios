//
//  UserManager.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import UIKit

import RxSwift

final class UserManager {
  
  // MARK: - Properties
  
  static let shared = UserManager()
  private let authRepository: AuthRepository
  
  // MARK: - User Options
  
  /// 로그인한 사용자의 아이디에 대한 변수
  @UserDefaultsWrapper<String>(key: "userID")
  private(set) var userID
  
  // MARK: - Haram Token
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  var hasToken: Bool {
    return accessToken != nil && refreshToken != nil && userID != nil
  }
  
  // MARK: - Initialization
  
  private init() { 
    self.authRepository = AuthRepositoryImpl()
  }
}

extension UserManager {
  
  /// Haram의 accessToken과 refreshToken을 업데이트합니다.
  /// - Parameters:
  ///   - accessToken: 새로운 accessToken
  ///   - refreshToken: 새로운 refreshToken
  func updateHaramToken(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
  
  func set(userID: String) {
    self.userID = userID
  }
  
  /// 유저의 정보를 전부 초기화합니다.
  func clearAllInformations() {
    self.userID = nil
    self.accessToken = nil
    self.refreshToken = nil
  }
  
  /// 가지고 있는 `refresh token`을 가지고 새로운 `access token`과 `refresh token`을 발급받습니다.
  func reissuanceAccessToken() -> Observable<Void> {
    return authRepository.reissuanceAccessToken(userID: UserManager.shared.userID ?? "")
      .map { result in
        switch result {
        case .success(let tokenData):
          self.updateHaramToken(
            accessToken: tokenData.accessToken,
            refreshToken: tokenData.refreshToken
          )
          return Void()
        case .failure(_):
          UserManager.shared.clearAllInformations()
          (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = LoginViewController()
        }
      }
  }
  
  
}
