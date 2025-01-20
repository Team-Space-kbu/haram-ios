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
        AlertManager.showAlert(message: .custom("현재 인트라넷 계정 가입 기능은 준비 중입니다.\n 빠른 시일 내에 이용 가능하도록 하겠습니다."))
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

