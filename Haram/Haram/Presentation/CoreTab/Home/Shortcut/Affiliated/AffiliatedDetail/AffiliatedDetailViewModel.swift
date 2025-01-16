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
    let didTapThumbnail: Observable<Void>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let affiliatedDetailModel = PublishRelay<AffiliatedDetailInfoViewModel>()
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
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
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireAffiliatedDetail(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapThumbnail
      .withLatestFrom(output.affiliatedDetailModel)
      .map { $0.imageURL }
      .subscribe(with: self) { owner, imageURL in
        guard let imageURL = imageURL else {
          owner.dependency.coordinator.showAlert(message: "해당 이미지는 확대할 수 없습니다")
          return
        }
        owner.dependency.coordinator.showZoomImageViewController(imageURL: imageURL)
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
}

extension AffiliatedDetailViewModel {
  private func inquireAffiliatedDetail(output: Output) {
    dependency.homeRepository.inquireAffiliatedDetail(id: payload.id)
      .subscribe(with: self, onSuccess: { owner, response in
        output.affiliatedDetailModel.accept(.init(
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
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
