//
//  AffiliatedDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import Foundation

import RxSwift
import RxCocoa

protocol AffiliatedDetailViewModelType {
  
  func inquireAffiliatedDetail(id: Int)
  
  var affiliatedDetailModel: Driver<AffiliatedDetailInfoViewModel> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class AffiliatedDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let homeRepository: HomeRepository
  
  private let affiliatedDetailModelRelay = BehaviorRelay<AffiliatedDetailInfoViewModel?>(value: nil)
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  init(homeRepository: HomeRepository = HomeRepositoryImpl()) {
    self.homeRepository = homeRepository
  }
  
}

extension AffiliatedDetailViewModel: AffiliatedDetailViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  func inquireAffiliatedDetail(id: Int) {
    homeRepository.inquireAffiliatedDetail(id: id)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.affiliatedDetailModelRelay.accept(.init(
          imageURL: URL(string: response.image),
          title: response.businessName,
          affiliatedLocationModel: .init(
            locationImageResource: .locationGray,
            locationContent: response.address
          ),
          affiliatedIntroduceModel: .init(
            title: "소개",
            content: response.description
          ),
          affiliatedBenefitModel: .init(
            title: "혜택",
            content: response.benefits
          ),
          affiliatedMapViewModel: .init(
            title: "지도",
            coordinateX: Double(response.xCoordinate)!,
            coordinateY: Double(response.yCoordinate)!
          )
        ))
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var affiliatedDetailModel: RxCocoa.Driver<AffiliatedDetailInfoViewModel> {
    affiliatedDetailModelRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
  }
}
