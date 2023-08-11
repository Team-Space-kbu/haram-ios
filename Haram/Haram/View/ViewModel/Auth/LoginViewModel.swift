//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import RxSwift
import RxCocoa

protocol LoginViewModelType {
  var userID: AnyObserver<String> { get }
  var password: AnyObserver<String> { get }
  
  var loginToken: Driver<(String?, String?)> { get }
}

final class LoginViewModel: LoginViewModelType {
  
  private let disposeBag = DisposeBag()
  
  var userID: AnyObserver<String>
  var password: AnyObserver<String>
  
  var loginToken: Driver<(String?, String?)>
  
  init() {
    let userIDForLogin = PublishSubject<String>()
    let passwordForLogin = PublishSubject<String>()
    let tokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.accessToken)
    let refreshTokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.refreshToken)
    
    userID = userIDForLogin.asObserver()
    password = passwordForLogin.asObserver()
    
    Observable.zip(
      userIDForLogin.do(onNext: { print("아디디 \($0)") }),
      passwordForLogin.do(onNext: { print("비디디 \($0)") })
    )
    .filter { !$0.isEmpty && !$1.isEmpty }
    .do(onNext: { print("아이디 \($0)\n비밀번호 \($1)") })
    .flatMapLatest {
      AuthService.shared.loginMember(
        request: .init(
          userID: $0,
          password: $1
        )
      )
    }
    .subscribe(onNext: { response in
      UserManager.shared.updatePLUBToken(accessToken: response.accessToken, refreshToken: response.refreshToken)
      tokenForLogin.onNext(UserManager.shared.accessToken)
      refreshTokenForLogin.onNext(UserManager.shared.refreshToken)
    }, onError: { error in
      guard let error = error as? HaramError,
      let description = error.description else { return }
      /// TODO: -로그인 실패 시 처리해야함
      print("로그인 시도에러 \(description)")
    })
    .disposed(by: disposeBag)
    
    loginToken = Observable.combineLatest(
      tokenForLogin, refreshTokenForLogin
    )
    .asDriver(onErrorDriveWith: .empty())
  }
}
