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
    let coordinator: CheckIDCoordinator
  }
  
  struct Payload {
    let userMail: String
  }
  
  struct Input {
    let didTappedContinueButton: Observable<String>
    let didTappedRerequestButton: Observable<Void>
    let didTapCancelButton: Observable<Void>
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
    
    input.didTapCancelButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTappedContinueButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, authCode in
        owner.verifyEmailAuthCode(output: output, authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    input.didTappedRerequestButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
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
        owner.dependency.coordinator.showAlert(message: "인증 코드가 다시 발송되었습니다!\n받은 메시지를 확인해 주세요.")
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func verifyEmailAuthCode(output: Output, authCode: String) {
    dependency.authRepository.verifyMailAuthCode(
      userMail: payload.userMail,
      authCode: authCode
    )
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.dependency.coordinator.showFindIDResultViewController(authCode: authCode)
        output.verifyEmailAuthCodeRelay.accept(authCode)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
