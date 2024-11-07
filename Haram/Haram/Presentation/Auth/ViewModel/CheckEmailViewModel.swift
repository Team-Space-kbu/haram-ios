//
//  CheckEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/1/24.
//

import RxSwift
import RxCocoa

final class CheckEmailViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  let payLoad: PayLoad
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
  }
  
  struct PayLoad {
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
  
  init(payLoad: PayLoad, dependency: Dependency) {
    self.payLoad = payLoad
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

extension CheckEmailViewModel {
  private func checkAuthCodeIsValid(authCode: String) -> Bool {
    let isValid = authCode.count == 6
    return isValid
  }
  
  func requestEmailAuthCode(output: Output) {
    dependency.authRepository.requestEmailAuthCode(userEmail: payLoad.userMail)
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
      userMail: payLoad.userMail,
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



//protocol CheckEmailViewModelType {
//  var emailAuthCode: AnyObserver<String> { get }
//  var verifyEmailAuthCode: Signal<String> { get }
//  var continueButtonIsEnabled: Driver<Bool> { get }
//  var errorMessage: Signal<HaramError> { get }
//  var successSendAuthCode: Signal<Void> { get }
//  
//  func verifyEmailAuthCode(userMail: String, authCode: String)
//  func requestEmailAuthCode(email: String)
//}
//
//final class CheckEmailViewModel: ViewModelType {
//  private let disposeBag = DisposeBag()
//  private let dependency: Dependency
//  private let payLoad: PayLoad
//  
////  private let verifyEmailAuthCodeRelay = PublishRelay<String>()
//////  private let emailAuthCodeSubject = BehaviorSubject<String>(value: "")
////  private let errorMessageRelay = PublishRelay<HaramError>()
////  private let successSendAuthCodeRelay = PublishRelay<Void>()
//  
//  struct PayLoad {
//    
//  }
//  
//  struct Dependency {
//    let authRepository: AuthRepository
//  }
//  
//  struct Input {
//    let didTappedContinueButton: Observable<Void>
//    let didTappedRerequestButton: Observable<Void>
//  }
//  
//  struct Output {
//    let verifyEmailAuthCodeRelay = PublishRelay<String>()
//    let errorMessageRelay = PublishRelay<HaramError>()
//    let successSendAuthCodeRelay = PublishRelay<Void>()
//  }
//  
//  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
//    self.authRepository = authRepository
//  }
//  
//  private func checkAuthCodeIsValid(authCode: String) -> Bool {
//    
//    let isValid = authCode.count == 6
//    return isValid
//  }
//}
//
//extension CheckEmailViewModel: CheckEmailViewModelType {
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
//  
//  
//}
