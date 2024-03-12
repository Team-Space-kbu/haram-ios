//
//  LoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

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

    authRepository.loginMember(
      request: .init(
        userID: userID,
        password: password,
        uuid: UserManager.shared.uuid!, 
        deviceInfo: .init(
          maker: "Apple",
          model: Device.getModelName(),
          osType: .IOS,
          osVersion: Device.getOsVersion()
        )
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
