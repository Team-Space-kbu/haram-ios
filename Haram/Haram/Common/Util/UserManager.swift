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
  
  @UserDefaultsWrapper<[UserTermsRequest]>(key: "userTermsRequests")
  private(set) var userTermsRequests
  
  /// 로그인한 디바이스에 대한 uuid
  @KeyChainWrapper<String>(key: "uuid")
  private(set) var uuid
  
  // MARK: - Haram Token
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  var hasToken: Bool {
    return accessToken != nil && refreshToken != nil && userID != nil
  }
  
  var hasUUID: Bool {
    return uuid != nil
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
  
  func set(uuid: String) {
    self.uuid = uuid
  }
  
  func set(userTermsRequests: [UserTermsRequest]) {
    self.userTermsRequests = userTermsRequests
  }
  
  /// 유저의 정보를 전부 초기화합니다.
  func clearAllInformations() {
    self.userID = nil
    self.accessToken = nil
    self.refreshToken = nil
    self.userTermsRequests = nil
  }
  
  /// 가지고 있는 `refresh token`을 가지고 새로운 `access token`과 `refresh token`을 발급받습니다.
  func reissuanceAccessToken() -> Single<Void> {
    return authRepository.reissuanceAccessToken(
      request: .init(
        userID: UserManager.shared.userID!,
        uuid: UserManager.shared.uuid!
      ))
    .map { [weak self] tokenData in
      guard let self = self else { return }
      self.updateHaramToken(
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken
      )
      return Void()
    }
  }
  
  
}
