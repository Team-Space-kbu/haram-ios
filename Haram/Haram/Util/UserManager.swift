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
  
  // MARK: - User Options
  
  /// 로그인한 사용자의 아이디에 대한 변수
  @UserDefaultsWrapper<String>(key: "userID")
  private(set) var userID
  
  // MARK: - Haram Token
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  // MARK: - Intranet Token
  @KeyChainWrapper<String>(key: "intranetToken")
  private(set) var intranetToken
  
  @KeyChainWrapper<String>(key: "xsrfToken")
  private(set) var xsrfToken
  
  @KeyChainWrapper<String>(key: "laravelSession")
  private(set) var laravelSession
  
  var hasIntranetToken: Bool {
    return intranetToken != nil && xsrfToken != nil && laravelSession != nil
  }
  
  var hasAccessToken: Bool { return accessToken != nil }
  var hasRefreshToken: Bool { return refreshToken != nil }
  
  // MARK: - Initialization
  
  private init() { }
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
  
  /// 인트라넷 관련 API를 위한 토큰값을 세팅합니다.
  func set(intranetToken: String, xsrfToken: String, laravelSession: String) {
    self.intranetToken = intranetToken
    self.xsrfToken = xsrfToken
    self.laravelSession = laravelSession
  }
  
  /// 유저의 정보를 전부 초기화합니다.
  func clearAllInformations() {
    self.userID = nil
    self.accessToken = nil
    self.refreshToken = nil
    
    self.intranetToken = nil
    self.xsrfToken = nil
    self.laravelSession = nil
  }
  
  /// 인트라넷관련 정보를 초기화합니다.
  func clearIntranetInformation() {
    self.intranetToken = nil
    self.xsrfToken = nil
    self.laravelSession = nil
  }
  
  /// 가지고 있는 `refresh token`을 가지고 새로운 `access token`과 `refresh token`을 발급받습니다.
  func reissuanceAccessToken() -> Observable<Void> {
    return AuthService.shared.reissuanceAccessToken(userID: UserManager.shared.userID ?? "")
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
