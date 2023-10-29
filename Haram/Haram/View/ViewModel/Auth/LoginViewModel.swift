//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import RxSwift
import RxCocoa

protocol LoginViewModelType {
  var tryLoginRequest: AnyObserver<(String, String)?> { get }
  
  var loginToken: Driver<(String?, String?)> { get }
  var errorMessage: Signal<String> { get }
  var isLoading: Driver<Bool> { get }
}

final class LoginViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let tryLoginRequestSubject = BehaviorSubject<(String, String)?>(value: nil)
  private let tokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.accessToken)
  private let refreshTokenForLogin = BehaviorSubject<String?>(value: UserManager.shared.refreshToken)
  private let errorMessageRelay = PublishRelay<String>()
  private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
  
  init() {
    tryLogin()
  }
}

// MARK: - Functionality

extension LoginViewModel {
  private func tryLogin() {
    tryLoginRequestSubject
      .compactMap { $0 }
      .do(onNext: { [weak self] id, password in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
        let message: String
        if id.isEmpty {
          message = password.isEmpty ? Constants.allEmptyMessage : Constants.idEmptyMessage
        } else if password.isEmpty && !id.isEmpty {
          message = Constants.passwordEmptyMessage
        } else {
          message = ""
        }
        self.errorMessageRelay.accept(message)
        self.isLoadingSubject.onNext(false)
      })
        .filter { !$0.isEmpty && !$1.isEmpty }
        .do(onNext: { [weak self] _ in
          guard let self = self else { return }
          self.isLoadingSubject.onNext(true)
        })
        .flatMapLatest {
          AuthService.shared.loginMember(
            request: .init(
              userID: $0,
              password: $1
            )
          )
        }
        .subscribe(with: self, onNext: { owner, result in
          switch result {
            case .success(let response):
              guard let (userID, _) = try? owner.tryLoginRequestSubject.value() else { return }
              
              UserManager.shared.updateHaramToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
              )
              
              UserManager.shared.set(userID: userID)
              
              owner.tokenForLogin.onNext(UserManager.shared.accessToken)
              owner.refreshTokenForLogin.onNext(UserManager.shared.refreshToken)
            case .failure(let error):
              guard let description = error.description else { return }
              /// TODO: -로그인 실패 시 처리해야함
              owner.errorMessageRelay.accept(description)
          }
          owner.isLoadingSubject.onNext(false)
        })
        .disposed(by: disposeBag)
  }
}

// MARK: - Constants

extension LoginViewModel {
  enum Constants {
    static let idEmptyMessage = "아이디를 입력해주세요."
    static let passwordEmptyMessage = "비밀번호를 입력해주세요."
    static let allEmptyMessage = "아이디와 비밀번호를 입력해주세요."
  }
}

extension LoginViewModel: LoginViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  
  var errorMessage: Signal<String> {
    errorMessageRelay
      .distinctUntilChanged()
      .asSignal(onErrorJustReturn: "")
  }
  
  var tryLoginRequest: AnyObserver<(String, String)?> {
    tryLoginRequestSubject.asObserver()
  }
  
  var loginToken: Driver<(String?, String?)> {
    Observable.zip(
      tokenForLogin, refreshTokenForLogin
    )
    .asDriver(onErrorDriveWith: .empty())
  }
}
