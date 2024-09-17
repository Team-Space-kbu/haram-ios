//
//  AuthRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import RxSwift

protocol AuthRepository {
  func signupUser(request: SignupUserRequest) -> Single<EmptyModel>
  func loginMember(request: LoginRequest) -> Single<LoginResponse>
  func reissuanceAccessToken(request: ReissuanceAccessTokenRequest) -> Single<LoginResponse>
  func loginIntranet(request: IntranetLoginRequest) -> Single<EmptyModel>
  func logoutUser(request: LogoutUserRequest) -> Single<EmptyModel>
  func requestEmailAuthCode(userEmail: String) -> Single<Bool>
  func updatePassword(request: UpdatePasswordRequest, userEmail: String) -> Single<Bool>
  func verifyMailAuthCode(userMail: String, authCode: String) -> Single<Bool>
  func verifyFindPassword(userMail: String, authCode: String) -> Single<String>
  func verifyFindID(userMail: String, authCode: String) -> Single<String>
  func inquireTermsSignUp() -> Single<[InquireTermsSignUpResponse]>
  func updateUserPassword(userID: String, request: UpdateUserPasswordRequest) -> Single<Bool>
}

final class AuthRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension AuthRepositoryImpl: AuthRepository {
  func verifyFindID(userMail: String, authCode: String) -> RxSwift.Single<String> {
    service.request(router: AuthRouter.verifyFindID(userMail, authCode), type: String.self)
  }
  
  func updateUserPassword(userID: String, request: UpdateUserPasswordRequest) -> Single<Bool> {
    service.request(router: AuthRouter.updateUserPassword(userID, request), type: Bool.self)
  }
  
  func inquireTermsSignUp() -> Single<[InquireTermsSignUpResponse]> {
    service.request(router: AuthRouter.inquireTermsSignUp, type: [InquireTermsSignUpResponse].self)
  }
  
  func verifyFindPassword(userMail: String, authCode: String) -> Single<String> {
    service.request(router: AuthRouter.verifyFindPassword(userMail, authCode), type: String.self)
  }
  
  func verifyMailAuthCode(userMail: String, authCode: String) -> Single<Bool> {
    service.request(router: AuthRouter.verifyMailAuthCode(userMail, authCode), type: Bool.self)
  }
  
  func updatePassword(request: UpdatePasswordRequest, userEmail: String) -> Single<Bool> {
    service.request(router: AuthRouter.updatePassword(request, userEmail), type: Bool.self)
  }
  
  func requestEmailAuthCode(userEmail: String) -> RxSwift.Single<Bool> {
    service.request(router: AuthRouter.requestEmailAuthCode(userEmail), type: Bool.self)
  }
  
  func signupUser(request: SignupUserRequest) -> Single<EmptyModel> {
    service.request(router: AuthRouter.signupUser(request), type: EmptyModel.self)
  }
  
  func loginMember(request: LoginRequest) -> Single<LoginResponse> {
    service.request(router: AuthRouter.loginMember(request), type: LoginResponse.self)
  }
  
  func reissuanceAccessToken(request: ReissuanceAccessTokenRequest) -> Single<LoginResponse> {
    service.request(router: AuthRouter.reissuanceAccessToken(request), type: LoginResponse.self)
  }
  
  func loginIntranet(request: IntranetLoginRequest) -> Single<EmptyModel> {
    service.request(router: AuthRouter.loginIntranet(request), type: EmptyModel.self)
  }
  
  func logoutUser(request: LogoutUserRequest) -> Single<EmptyModel> {
    service.request(router: AuthRouter.logoutUser(request), type: EmptyModel.self)
  }
  
}
