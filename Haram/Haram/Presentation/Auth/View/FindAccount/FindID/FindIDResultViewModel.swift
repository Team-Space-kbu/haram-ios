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
  private let payLoad: PayLoad
  private let dependency: Dependency
  
  struct Dependency {
    let authRepository: AuthRepository
  }
  
  struct PayLoad {
    let userMail: String
    let authCode: String
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let foundUserID = PublishRelay<String>()
  }
  
  init(payLoad: PayLoad, dependency: Dependency) {
    self.payLoad = payLoad
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
      userMail: payLoad.userMail,
      authCode: payLoad.authCode
    )
    .subscribe(with: self) { owner, response in
      output.foundUserID.accept(response)
    }
    .disposed(by: disposeBag)
  }
}
