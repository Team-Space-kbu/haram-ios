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
    
    inquireAffiliatedList
      .map { $0.map { AffiliatedCollectionViewCellModel(response: $0) } }
      .subscribe(with: self) { owner, model in
        owner.affiliatedModelRelay.accept(model)
      }
      .disposed(by: disposeBag)
    
//    successInquireAffiliatedList
//      .map { $0.map { AffiliatedCollectionViewCellModel(response: $0) } }
//      .bind(to: affiliatedModelRelay)
//      .disposed(by: disposeBag)
  }
}

extension AffiliatedViewModel: AffiliatedViewModelType {
  var affiliatedModel: Driver<[AffiliatedCollectionViewCellModel]> {
    affiliatedModelRelay.asDriver(onErrorJustReturn: [])
  }
}
