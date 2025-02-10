//
//  CheckAuthCodeViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/5/24.
//

import Foundation

import RxSwift
import RxCocoa

final class CheckAuthCodeViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let userMail: String
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: CheckAuthCodeCoordinator
    
  }
  
  struct Input {
    let didEditAuthCode: Observable<String>
    let didTapContinueButton: Observable<Void>
    let didTapCancelButton: Observable<Void>
  }
  
  struct Output {
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapContinueButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(input.didEditAuthCode)
      .subscribe(with: self) { owner, authCode in
        owner.verifyEmailAuthCode(output: output, authCode: authCode)
      }
      .disposed(by: disposeBag)
    
    input.didTapCancelButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension CheckAuthCodeViewModel {
  private func isValidAuthCode(authCode: String) -> Bool {
    return authCode.count == 6
  }
  
  func verifyEmailAuthCode(output: Output, authCode: String) {
    
    if !isValidAuthCode(authCode: authCode) {
      output.errorMessageRelay.accept(.unvalidAuthCodeFormat)
      return
    }
    
    let userMail = payload.userMail
    
    dependency.authRepository.verifyMailAuthCode(userMail: userMail, authCode: authCode)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.dependency.coordinator.showRegisterViewController(authCode: authCode)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
