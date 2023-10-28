//
//  CheckReservationViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/27/23.
//

import RxSwift
import RxCocoa

protocol CheckReservationViewModelType {
  
}

final class CheckReservationViewModel {
  
  private let disposeBag = DisposeBag()
  
  init() {
    inquireRothemReservationAuthCode()
  }
  
  private func inquireRothemReservationAuthCode() {
    let inquireRothemReservationAuthCode = RothemService.shared.inquireRothemReservationAuthCode(userID: UserManager.shared.userID!)
    
    inquireRothemReservationAuthCode
      .subscribe(with: self) { owner, authCode in
        
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
}
