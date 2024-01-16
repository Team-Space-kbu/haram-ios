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
  func reissuanceAccessToken(userID: String) -> Observable<Result<LoginResponse, HaramError>>
  func loginIntranet(request: IntranetLoginRequest) -> Observable<Result<EmptyModel, HaramError>>
  func logoutUser(userID: String) -> Observable<Result<EmptyModel, HaramError>>
}

final class AuthRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension AuthRepositoryImpl: AuthRepository {
  func signupUser(request: SignupUserRequest) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.signupUser(request), type: EmptyModel.self)
  }
  
  func loginMember(request: LoginRequest) -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.loginMember(request), type: LoginResponse.self)
  }
  
  func reissuanceAccessToken(userID: String) -> Observable<Result<LoginResponse, HaramError>> {
    service.request(router: AuthRouter.reissuanceAccessToken(userID), type: LoginResponse.self)
  }
  
  func loginIntranet(request: IntranetLoginRequest) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.loginIntranet(request), type: EmptyModel.self)
  }
  
  func logoutUser(userID: String) -> Observable<Result<EmptyModel, HaramError>> {
    service.request(router: AuthRouter.logoutUser(userID), type: EmptyModel.self)
  }
  
}
