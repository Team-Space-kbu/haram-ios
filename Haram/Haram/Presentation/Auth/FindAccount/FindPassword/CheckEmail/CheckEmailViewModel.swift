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
  let payload: Payload
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: CheckEmailCoordinator
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

extension CheckEmailViewModel {
  private func checkAuthCodeIsValid(authCode: String) -> Bool {
    let isValid = authCode.count == 6
    return isValid
  }
  
  func requestEmailAuthCode(output: Output) {
    dependency.authRepository.requestEmailAuthCode(userEmail: payload.userMail)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.dependency.coordinator.showAlert(message: "인증 코드가 성공적으로 재발송되었습니다.\n메시지를 확인해 주세요.")
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
        owner.dependency.coordinator.showUpdatePasswordViewController(authCode: authCode)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
