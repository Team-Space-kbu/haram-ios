//
//  FindPasswordViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/26/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol FindPasswordViewModelType {
  
  var findPasswordEmail: AnyObserver<String> { get }
  var isContinueButtonEnabled: Driver<Bool> { get }
}

final class FindPasswordViewModel {
  
  private let disposeBag = DisposeBag()
  private let findPasswordEmailSubject = BehaviorSubject<String>(value: "")
  
}

extension FindPasswordViewModel: FindPasswordViewModelType {
  var findPasswordEmail: RxSwift.AnyObserver<String> {
    findPasswordEmailSubject.asObserver()
  }
  
  var isContinueButtonEnabled: RxCocoa.Driver<Bool> {
    findPasswordEmailSubject
      .map {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@bible\.ac\.kr$"#
        
        // NSPredicate를 사용하여 정규표현식과 매칭하는지 확인
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        // 입력된 이메일이 유효한지 확인
        return emailPredicate.evaluate(with: $0 + "@bible.ac.kr")
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  
}
