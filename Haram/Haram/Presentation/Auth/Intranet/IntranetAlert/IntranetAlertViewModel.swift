//
//  IntranetAlertViewModel.swift
//  Haram
//
//  Created by 이건준 on 12/21/24.
//

import RxSwift

final class IntranetAlertViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  struct Payload {
    
  }
  
  struct Dependency {
    let coordinator: IntranetAlertCoordinator
  }
  
  struct Input {
    let didTapCancelButton: Observable<Void>
    let didTapConfirmButton: Observable<Void>
  }
  
  struct Output {
    
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapCancelButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popToRootViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapConfirmButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.showIntranetLoginViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
}
