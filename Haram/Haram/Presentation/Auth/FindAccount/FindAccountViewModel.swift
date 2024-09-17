//
//  FindAccountViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/1/24.
//

import RxSwift

final class FindAccountViewModel: ViewModelType {
  private let dependency: Dependency
  private let disposeBag = DisposeBag()
  
  struct Dependency {
    let coordinator: FindAccountCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let didTapFindIDButton: Observable<Void>
    let didTapFindPasswordButton: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapFindIDButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showFindIDViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapFindPasswordButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showFindPasswordViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}
