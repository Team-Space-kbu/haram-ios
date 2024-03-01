//
//  CheckEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/1/24.
//

import RxSwift
import RxCocoa

protocol CheckEmailViewModelType {
  var emailAuthCode: AnyObserver<String> { get }
  func verifyEmailAuthCode(userMail: String, authCode: String)
  var isVerifyEmailAuthCode: Signal<Bool> { get }
  var continueButtonIsEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class CheckEmailViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isVerifyEmailAuthCodeRelay = PublishRelay<Bool>()
  private let emailAuthCodeSubject = BehaviorSubject<String>(value: "")
  private let errorMessageRelay = PublishRelay<HaramError>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  private func checkAuthCodeIsValid(authCode: String) -> Bool {
    
    let isValid = authCode.count == 6
    return isValid
  }
}

extension CheckEmailViewModel: CheckEmailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  
  var continueButtonIsEnabled: RxCocoa.Driver<Bool> {
    emailAuthCodeSubject
      .withUnretained(self)
      .map { $0.checkAuthCodeIsValid(authCode: $1) }
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var emailAuthCode: RxSwift.AnyObserver<String> {
    emailAuthCodeSubject.asObserver()
  }
  
  var isVerifyEmailAuthCode: RxCocoa.Signal<Bool> {
    isVerifyEmailAuthCodeRelay.asSignal()
  }
  
  func verifyEmailAuthCode(userMail: String, authCode: String) {
    authRepository.verifyMailAuthCode(userMail: userMail + "@bible.ac.kr", authCode: authCode)
      .subscribe(with: self) { owner, result in
        switch result {
        case let .success(isVerify):
          owner.isVerifyEmailAuthCodeRelay.accept(isVerify)
        case let .failure(error):
          owner.errorMessageRelay.accept(error)
        }
      }
      .disposed(by: disposeBag)
  }
  
  
}
