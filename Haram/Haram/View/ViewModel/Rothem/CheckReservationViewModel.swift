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
    inquireRothemReservationInfo()
  }
  
  private func inquireRothemReservationInfo() {
    let inquireRothemReservationInfo = RothemService.shared.inquireRothemReservationInfo(userID: UserManager.shared.userID!)
    
    inquireRothemReservationInfo
      .subscribe(with: self) { owner, response in
        print("들어오나 \(response)")
      }
      .disposed(by: disposeBag)
  }
}

extension CheckReservationViewModel: CheckReservationViewModelType {
  
}
