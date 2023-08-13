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
  func registerMember(request: RegisterMemberRequest) -> Observable<Result<RegisterMemberResponse, HaramError>> {
    service.request(router: AuthRouter.registerMember(request), type: RegisterMemberResponse.self)
  }
  
  func loginMember(request: LoginRequest) -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.loginMember(request), type: LoginResponse.self)
  }
  
  func reissuanceAccessToken() -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.reissuanceAccessToken, type: LoginResponse.self)
  }
  
  func loginIntranet(request: IntranetLoginRequest) -> Observable<String> {
    service.intranetRequest(router: AuthRouter.loginIntranet(request))
  }
  
  func requestIntranetToken() -> Observable<Result<RequestIntranetTokenResponse, HaramError>> {
    service.request(router: AuthRouter.requestIntranetToken, type: RequestIntranetTokenResponse.self)
  }
  
  func signupMember(request: SignupMemberRequest) -> Observable<Result<SearchBookResponse, HaramError>> {
    service.request(router: AuthRouter.signupMember(request), type: SearchBookResponse.self)
  }
}
