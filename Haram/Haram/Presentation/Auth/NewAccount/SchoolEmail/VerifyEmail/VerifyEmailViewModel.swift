//
//  VerifyEmailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/3/24.
//

import Foundation

import RxSwift
import RxCocoa

final class VerifyEmailViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: VerifyEmailCoordinator
  }
  
  struct Input {
    let didEditSchoolEmail: Observable<String>
    let didTapContinueButton: Observable<Void>
    let didTapCancelButton: Observable<Void>
  }
  
  struct Output {
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapContinueButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(input.didEditSchoolEmail)
      .subscribe(with: self) { owner, email in
        owner.requestEmailAuthCode(output: output, email: email)
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

extension VerifyEmailViewModel {
  private func isValidBibleEmail(_ email: String) -> Bool {
      // 이메일 형식 정규식
      let emailRegex = "[A-Z0-9a-z._%+-]+@bible\\.ac\\.kr"
      
      // NSPredicate를 사용하여 정규식과 매칭되는지 확인
      let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
      
      return emailPredicate.evaluate(with: email)
  }
  
  private func requestEmailAuthCode(output: Output, email: String) {
    let userEmail = email + "@bible.ac.kr"
    dependency.authRepository.requestEmailAuthCode(userEmail: userEmail)
        .subscribe(with: self, onSuccess: { owner, _ in
          owner.dependency.coordinator.showCheckAuthCodeViewController(userMail: userEmail)
        }, onFailure: { owner, error in
          guard let error = error as? HaramError else { return }
          output.errorMessageRelay.accept(error)
        })
        .disposed(by: disposeBag)
    }
}
