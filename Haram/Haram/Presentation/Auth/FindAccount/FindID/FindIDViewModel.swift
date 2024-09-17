//
//  FindIDViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/17/24.
//

import RxSwift
import RxCocoa

final class FindIDViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let payload: Payload
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: FindIDCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let didUpdatedUserMail: Observable<String>
    let didTapSendButton: Observable<Void>
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
    
    input.didTapSendButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(input.didUpdatedUserMail)
      .subscribe(with: self) { owner, userMail in
        owner.requestEmailAuthCode(output: output, email: userMail)
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

extension FindIDViewModel {
  func requestEmailAuthCode(output: Output, email: String) {
    let userEmail = email + "@bible.ac.kr"
    dependency.authRepository.requestEmailAuthCode(userEmail: userEmail)
      .subscribe(with: self, onSuccess: { owner, _ in
        owner.dependency.coordinator.showCheckEmailViewController(userMail: userEmail)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
