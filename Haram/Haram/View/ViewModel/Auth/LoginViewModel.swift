//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import RxSwift
import RxCocoa

protocol LoginViewModelType {
  var tryLoginRequest: AnyObserver<(String, String)> { get }
  
  var loginToken: Driver<(String?, String?)> { get }
}

final class LoginViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let tryLoginRequestSubject = PublishSubject<(String, String)>()
  private let tokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.accessToken)
  private let refreshTokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.refreshToken)
  
  init() {
    tryLogin()
  }
}

// MARK: - Functionality

extension LoginViewModel {
  private func tryLogin() {
    tryLoginRequestSubject
      .do(onNext: { print("아이디 \($0)\n 비밀번호 \($1)") })
        .filter { !$0.isEmpty && !$1.isEmpty }
        .flatMapLatest {
          AuthService.shared.loginMember(
            request: .init(
              userID: $0,
              password: $1
            )
          )
        }
        .subscribe(with: self, onNext: { owner, response in
          UserManager.shared.updatePLUBToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
          )
          owner.tokenForLogin.onNext(UserManager.shared.accessToken)
          owner.refreshTokenForLogin.onNext(UserManager.shared.refreshToken)
        }, onError: { _, error in
          guard let error = error as? HaramError,
                let description = error.description else { return }
          /// TODO: -로그인 실패 시 처리해야함
          print("로그인 시도에러: \(description)")
        })
        .disposed(by: disposeBag)
  }
}

extension LoginViewModel: LoginViewModelType {
  var tryLoginRequest: AnyObserver<(String, String)> {
    tryLoginRequestSubject.asObserver()
  }
  
  var loginToken: Driver<(String?, String?)> {
    Observable.combineLatest(
      tokenForLogin, refreshTokenForLogin
    )
    .asDriver(onErrorDriveWith: .empty())
  }
}
