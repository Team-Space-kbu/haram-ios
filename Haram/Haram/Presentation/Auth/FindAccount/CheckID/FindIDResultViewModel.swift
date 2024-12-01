//
//  FindIDResultViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/6/24.
//

import RxSwift
import RxCocoa

final class FindIDResultViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let payload: Payload
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
  }
  
  struct Payload {
    let userMail: String
    let authCode: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let foundUserID = PublishRelay<String>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.findID(output: output)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension FindIDResultViewModel {
  private func findID(output: Output) {
    dependency.authRepository.verifyFindID(
      userMail: payload.userMail,
      authCode: payload.authCode
    )
    .subscribe(with: self) { owner, response in
      output.foundUserID.accept(response)
    }
    .disposed(by: disposeBag)
  }
}
