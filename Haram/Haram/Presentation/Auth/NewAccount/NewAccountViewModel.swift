//
//  NewAccountViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/1/24.
//

import RxSwift

final class NewAccountViewModel: ViewModelType {
  private let dependency: Dependency
  private let disposeBag = DisposeBag()
  
  struct Dependency {
    let coordinator: NewAccountCoordinator
  }
  
  struct Payload {
    
  }
  
  struct Input {
    let didTapSchoolAccountButton: Observable<Void>
    let didTapIntranetAccountButton: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapSchoolAccountButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showVerifyEmailViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapIntranetAccountButton
      .subscribe(with: self) { owner, _ in
        print("인트라넷계정생성 버튼 클릭")
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

