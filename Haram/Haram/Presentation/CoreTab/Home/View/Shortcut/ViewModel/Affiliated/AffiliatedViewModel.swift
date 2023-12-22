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
  var isLoading: Driver<Bool> { get }
}

final class AffiliatedViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let affiliatedModelRelay = BehaviorRelay<[AffiliatedCollectionViewCellModel]>(value: [])
  private let isLoadingSubject     = PublishSubject<Bool>()
  
  init() {
    tryInquireAffiliated()
  }
  
  private func tryInquireAffiliated() {
    let inquireAffiliatedList = HomeService.shared.inquireAffiliatedList()
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    inquireAffiliatedList
      .map { $0.map { AffiliatedCollectionViewCellModel(response: $0) } }
      .subscribe(with: self) { owner, model in
        owner.affiliatedModelRelay.accept(model)
        owner.isLoadingSubject.onNext(false)
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
    affiliatedModelRelay.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: [])
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}
