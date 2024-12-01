//
//  AffiliatedDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import Foundation

import RxSwift
import RxCocoa

final class AffiliatedDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let id: Int
  }
  
  struct Dependency {
    let homeRepository: HomeRepository
    let coordinator: AffiliatedDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
  }
  
  struct Output {
    let affiliatedDetailModelRelay = PublishRelay<AffiliatedDetailInfoViewModel>()
    let errorMessageRelay = PublishRelay<HaramError>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireAffiliatedDetail(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
}

extension AffiliatedDetailViewModel {
  private func inquireAffiliatedDetail(output: Output) {
    dependency.homeRepository.inquireAffiliatedDetail(id: payload.id)
      .subscribe(with: self, onSuccess: { owner, response in
        output.affiliatedDetailModelRelay.accept(.init(
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
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
