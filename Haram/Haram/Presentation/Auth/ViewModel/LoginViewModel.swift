//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import Foundation

import RxSwift
import RxCocoa

protocol LoginViewModelType {
  func loginMember(userID: String, password: String)
  
  var errorMessage: Signal<String> { get }
  var successLogin: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
}

final class LoginViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let errorMessageRelay      = PublishRelay<String?>()
  private let isLoadingSubject       = BehaviorSubject<Bool>(value: false)
  private let successLoginRelay      = PublishRelay<Void>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
}

// MARK: - Functionality

extension LoginViewModel {
  
  func loginMember(userID: String, password: String) {
    isLoadingSubject.onNext(true)
    let message: String?
    if userID.isEmpty {
      message = password.isEmpty ? Constants.allEmptyMessage : Constants.idEmptyMessage
    } else if password.isEmpty && !userID.isEmpty {
      message = Constants.passwordEmptyMessage
    } else {
      message = nil
    }
    self.errorMessageRelay.accept(message)
    self.isLoadingSubject.onNext(false)
    
    guard !userID.isEmpty && !password.isEmpty else { return }
    
    self.isLoadingSubject.onNext(true)
    
    authRepository.loginMember(
      request: .init(
        userID: userID,
        password: password,
        uuid: UserManager.shared.uuid!
      )
    )
    .subscribe(with: self, onNext: { owner, result in
      switch result {
        case .success(let response):
          
          UserManager.shared.updateHaramToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
          )
          
          UserManager.shared.set(userID: userID)
        owner.successLoginRelay.accept(())

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
  var successLogin: RxCocoa.Signal<Void> {
    successLoginRelay.asSignal()
  }
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  
  var errorMessage: Signal<String> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }

}
