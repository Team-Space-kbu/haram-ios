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
    
    let successInquireRothemReservationAuthCode = inquireRothemReservationAuthCode
      .compactMap { result -> String? in
        guard case let .success(response) = result else { return nil }
        return response
      }
    
    successInquireRothemReservationAuthCode
      .subscribe(with: self) { owner, authCode in
        
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
}
