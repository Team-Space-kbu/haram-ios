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
  private let homeRepository: HomeRepository
  
  private let affiliatedModelRelay = BehaviorRelay<[AffiliatedCollectionViewCellModel]>(value: [])
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl()) {
    self.homeRepository = homeRepository
    tryInquireAffiliated()
  }
  
  private func tryInquireAffiliated() {
    let inquireAffiliatedList = homeRepository.inquireAffiliatedList()
    
    inquireAffiliatedList
      .map { $0.map { AffiliatedCollectionViewCellModel(response: $0) } }
      .subscribe(with: self) { owner, model in
        owner.affiliatedModelRelay.accept(model)
      }
      .disposed(by: disposeBag)
  }
}

extension AffiliatedViewModel: AffiliatedViewModelType {
  var affiliatedModel: Driver<[AffiliatedCollectionViewCellModel]> {
    affiliatedModelRelay.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: [])
  }
}
