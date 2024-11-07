//
//  FindPasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/26/24.
//

import RxSwift
import RxCocoa

final class FindPasswordViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let payLoad: PayLoad
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
  }
  
  struct PayLoad {
    
  }
  
  struct Input {
    let didUpdatedUserMail: Observable<String>
    let didTappedSendButton: Observable<Void>
  }
  
  struct Output {
    let successSendAuthCodeRelay = PublishRelay<String>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(payLoad: PayLoad, dependency: Dependency) {
    self.payLoad = payLoad
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTappedSendButton
      .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(input.didUpdatedUserMail)
      .subscribe(with: self) { owner, userMail in
        owner.requestEmailAuthCode(output: output, email: userMail)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension FindPasswordViewModel {
  func requestEmailAuthCode(output: Output, email: String) {
    dependency.authRepository.requestEmailAuthCode(userEmail: email + "@bible.ac.kr")
      .subscribe(with: self, onSuccess: { owner, _ in
        output.successSendAuthCodeRelay.accept(email + "@bible.ac.kr")
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
