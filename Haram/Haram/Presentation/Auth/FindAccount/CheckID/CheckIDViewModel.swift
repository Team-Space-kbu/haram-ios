//
//  CheckIDViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/4/24.
//

import RxSwift
import RxCocoa

final class CheckIDViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  let payload: Payload
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
  }
  
  struct Payload {
    let userMail: String
  }
  
  struct Input {
    let didTappedContinueButton: Observable<String>
    let didTappedRerequestButton: Observable<Void>
  }
  
  struct Output {
    let verifyEmailAuthCodeRelay = PublishRelay<String>()
    let errorMessageRelay = PublishRelay<HaramError>()
    let successSendAuthCodeRelay = PublishRelay<Void>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTappedContinueButton
      .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, authCode in
        owner.verifyEmailAuthCode(output: output, authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    input.didTappedRerequestButton
      .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, _ in
        owner.requestEmailAuthCode(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension CheckIDViewModel {
  private func checkAuthCodeIsValid(authCode: String) -> Bool {
    let isValid = authCode.count == 6
    return isValid
  }
  
  func requestEmailAuthCode(output: Output) {
    dependency.authRepository.requestEmailAuthCode(userEmail: payload.userMail)
      .subscribe(with: self, onSuccess: { owner, _ in
        output.successSendAuthCodeRelay.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func verifyEmailAuthCode(output: Output, authCode: String) {
    dependency.authRepository.verifyFindPassword(
      userMail: payload.userMail,
      authCode: authCode
    )
      .subscribe(with: self, onSuccess: { owner, authCode in
        output.verifyEmailAuthCodeRelay.accept(authCode)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

//extension CheckIDViewModel: CheckIDViewModelType {
//  var successSendAuthCode: RxCocoa.Signal<Void> {
//    successSendAuthCodeRelay.asSignal()
//  }
//
//  var errorMessage: RxCocoa.Signal<HaramError> {
//    errorMessageRelay.asSignal()
//  }
//
//
//  var continueButtonIsEnabled: RxCocoa.Driver<Bool> {
//    emailAuthCodeSubject
//      .withUnretained(self)
//      .map { $0.checkAuthCodeIsValid(authCode: $1) }
//      .asDriver(onErrorDriveWith: .empty())
//  }
//
//  var emailAuthCode: RxSwift.AnyObserver<String> {
//    emailAuthCodeSubject.asObserver()
//  }
//
//  var verifyEmailAuthCode: RxCocoa.Signal<String> {
//    verifyEmailAuthCodeRelay.asSignal()
//  }
//
//  func requestEmailAuthCode(email: String) {
//    authRepository.requestEmailAuthCode(userEmail: email)
//      .subscribe(with: self, onSuccess: { owner, _ in
//        owner.successSendAuthCodeRelay.accept(())
//      }, onFailure: { owner, error in
//        guard let error = error as? HaramError else { return }
//        owner.errorMessageRelay.accept(error)
//      })
//      .disposed(by: disposeBag)
//  }
//
//  func verifyEmailAuthCode(userMail: String, authCode: String) {
//    authRepository.verifyFindPassword(userMail: userMail, authCode: authCode)
//      .subscribe(with: self, onSuccess: { owner, authCode in
//        owner.verifyEmailAuthCodeRelay.accept(authCode)
//      }, onFailure: { owner, error in
//        guard let error = error as? HaramError else { return }
//        owner.errorMessageRelay.accept(error)
//      })
//      .disposed(by: disposeBag)
//  }
//}
//
