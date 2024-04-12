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
  
  var errorMessage: Signal<HaramError> { get }
  var successLogin: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
}

final class LoginViewModel {
  
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let errorMessageRelay      = PublishRelay<HaramError>()
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
    .subscribe(with: self, onSuccess: { owner, response in    
      UserManager.shared.updateHaramToken(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken
      )
      
      UserManager.shared.set(userID: userID)
      owner.successLoginRelay.accept(())
      owner.isLoadingSubject.onNext(false)
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error)
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
  
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .asSignal(onErrorSignalWith: .empty())
  }
  
}
