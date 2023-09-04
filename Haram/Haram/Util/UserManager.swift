//
//  UserManager.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

import RxSwift
import UIKit

final class UserManager {
  
  // MARK: - Properties
  
  static let shared = UserManager()
  
  // MARK: - User Options
  
  /// 최초 실행 여부를 확인하는 변수
  @UserDefaultsWrapper<String>(key: "userID")
  private(set) var userID
  
  // MARK: - PLUB Token
  
  @KeyChainWrapper<String>(key: "signToken")
  private(set) var signToken
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  @KeyChainWrapper<String>(key: "fcmToken")
  private(set) var fcmToken
  
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
  
  /// PLUB의 accessToken과 refreshToken을 업데이트합니다.
  /// - Parameters:
  ///   - accessToken: 새로운 accessToken
  ///   - refreshToken: 새로운 refreshToken
  func updatePLUBToken(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
  
  func set(userID: String) {
    self.userID = userID
  }
  
  /// 플럽 회원가입에 필요한 `SignToken`을 세팅합니다.
  func set(signToken: String) {
    self.signToken = signToken
  }
  
  /// 플럽 푸시 알림에 필요한 `firebase cloud messaging Token`을 세팅합니다.
  func set(fcmToken: String) {
    self.fcmToken = fcmToken
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
  
  func clearToken() {
    self.accessToken = nil
    self.refreshToken = nil
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
          self.updatePLUBToken(
            accessToken: tokenData.accessToken,
            refreshToken: tokenData.refreshToken
          )
        case .failure(_):
          UserManager.shared.clearAllInformations()
          (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = LoginViewController()
        }
//        guard case let .success(tokenData) = result else { return }
//        self.updatePLUBToken(accessToken: tokenData.accessToken, refreshToken: tokenData.refreshToken)
      }
  }
  
  
}
