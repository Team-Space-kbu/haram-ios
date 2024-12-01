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

final class LoginViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
//  private let successLoginRelay      = PublishRelay<Void>()
  struct Payload {
    
  }
  
  struct Dependency {
    let coordinator: LoginCoordinator
    let authRepository: AuthRepository
  }
  
  struct Input {
    let didEditEmailField: Observable<String>
    let didEditPasswordField: Observable<String>
    let didTappedLoginButton: Observable<Void>
    let didTappedNewAccountButton: Observable<Void>
    let didTappedFindAccountButton: Observable<Void>
  }
  
  struct Output {
    let errorMessage = PublishRelay<HaramError>()
    let isLoading    = BehaviorRelay<Bool>(value: false)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTappedLoginButton
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditEmailField,
          input.didEditPasswordField
        )
      )
      .subscribe(with: self) { owner, result in
        let (userID, password) = result
        owner.loginMember(output: output, userID: userID, password: password)
      }
      .disposed(by: disposeBag)
    
    input.didTappedNewAccountButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showTermsOfUseViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTappedFindAccountButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showFindAccountViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

// MARK: - Functionality

extension LoginViewModel {
  
  func loginMember(output: Output, userID: String, password: String) {
    output.isLoading.accept(true)
    
    if !UserManager.shared.hasUUID {
      UserManager.shared.set(uuid: UUID().uuidString)
    }
    
    dependency.authRepository.loginMember(
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
      output.isLoading.accept(false)
      owner.dependency.coordinator.didFinishLogin()
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
      output.isLoading.accept(false)
    })
    .disposed(by: disposeBag)
    
  }
}
