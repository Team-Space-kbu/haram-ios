//
//  AuthRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import RxSwift

final class AuthService {
  
  static let shared = AuthService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension AuthService {
  func registerMember(request: RegisterMemberRequest) -> Observable<RegisterMemberResponse> {
    service.request(router: AuthRouter.registerMember(request), type: RegisterMemberResponse.self)
  }
  
  func loginMember(request: LoginRequest) -> Observable<LoginResponse> {
    service.request(router: AuthRouter.loginMember(request), type: LoginResponse.self)
  }
}
