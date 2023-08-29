//
//  AffiliatedViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import RxSwift
import RxCocoa

protocol AffiliatedViewModelType {
  var affiliatedModel: Driver<[AffiliatedCollectionViewCellModel]> { get }
}

final class AffiliatedViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let affiliatedModelRelay = BehaviorRelay<[AffiliatedCollectionViewCellModel]>(value: [])
  
  init() {
    tryInquireAffiliated()
  }
  
  private func tryInquireAffiliated() {
    let inquireAffiliatedList = HomeService.shared.inquireAffiliatedList()
    
    let successInquireAffiliatedList = inquireAffiliatedList.compactMap { result -> [InquireAffiliatedResponse]? in
      guard case .success(let response) = result else { return nil }
      return response
    }
    
    successInquireAffiliatedList
      .map { $0.map { AffiliatedCollectionViewCellModel(response: $0) } }
      .bind(to: affiliatedModelRelay)
      .disposed(by: disposeBag)
  }
}

extension AffiliatedViewModel: AffiliatedViewModelType {
  var affiliatedModel: Driver<[AffiliatedCollectionViewCellModel]> {
    affiliatedModelRelay.asDriver(onErrorJustReturn: [])
  }
}
