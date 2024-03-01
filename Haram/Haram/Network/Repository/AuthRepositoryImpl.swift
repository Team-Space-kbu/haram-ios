//
//  AuthRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import RxSwift

protocol AuthRepository {
  func signupUser(request: SignupUserRequest) -> Observable<Result<EmptyModel, HaramError>>
  func loginMember(request: LoginRequest) -> Observable<Result<LoginResponse, HaramError>>
  func reissuanceAccessToken(request: ReissuanceAccessTokenRequest) -> Observable<Result<LoginResponse, HaramError>>
  func loginIntranet(request: IntranetLoginRequest) -> Observable<Result<EmptyModel, HaramError>>
  func logoutUser(request: LogoutUserRequest) -> Observable<Result<EmptyModel, HaramError>>
  func requestEmailAuthCode(userEmail: String) -> Single<Bool>
  func updatePassword(request: UpdatePasswordRequest, userEmail: String) -> Observable<Result<Bool, HaramError>>
  func verifyMailAuthCode(userMail: String, authCode: String) -> Observable<Result<Bool, HaramError>>
}

final class AuthRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension AuthRepositoryImpl: AuthRepository {
  func verifyMailAuthCode(userMail: String, authCode: String) -> RxSwift.Observable<Result<Bool, HaramError>> {
    service.request(router: AuthRouter.verifyMailAuthCode(userMail, authCode), type: Bool.self)
  }
  
  func updatePassword(request: UpdatePasswordRequest, userEmail: String) -> RxSwift.Observable<Result<Bool, HaramError>> {
    service.request(router: AuthRouter.updatePassword(request, userEmail), type: Bool.self)
  }
  
  func requestEmailAuthCode(userEmail: String) -> RxSwift.Single<Bool> {
    service.betarequest(router: AuthRouter.requestEmailAuthCode(userEmail), type: Bool.self)
  }
  
  func signupUser(request: SignupUserRequest) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.signupUser(request), type: EmptyModel.self)
  }
  
  func loginMember(request: LoginRequest) -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.loginMember(request), type: LoginResponse.self)
  }
  
  func reissuanceAccessToken(request: ReissuanceAccessTokenRequest) -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.reissuanceAccessToken(request), type: LoginResponse.self)
  }
  
  func loginIntranet(request: IntranetLoginRequest) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.loginIntranet(request), type: EmptyModel.self)
  }
  
  func logoutUser(request: LogoutUserRequest) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.logoutUser(request), type: EmptyModel.self)
  }
  
}
