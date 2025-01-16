//
//  AffiliatedListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import Foundation
import RxSwift
import RxCocoa

final class AffiliatedListViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private(set) var affiliatedModel: [AffiliatedTableViewCellModel] = []
  
  struct Payload {
    
  }
  
  struct Dependency {
    let homeRepository: HomeRepository
    let coordinator: AffiliatedListCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapAffiliatedCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let reloadData   = PublishRelay<Void>()
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireAffiliated(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireAffiliated(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapAffiliatedCell
      .subscribe(with: self) { owner, indexPath in
        let affiliatedModel = owner.affiliatedModel[indexPath.row]
        owner.dependency.coordinator.showAffiliatedDetailViewController(affiliatedModel: affiliatedModel)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension AffiliatedListViewModel {
  func inquireAffiliated(output: Output) {
    let inquireAffiliatedModel = dependency.homeRepository.inquireAffiliatedModel()
    
    inquireAffiliatedModel
      .map { affiliated in
        affiliated.map { AffiliatedTableViewCellModel(response: $0) }
      }
      .subscribe(with: self, onSuccess: { owner, model in
        owner.affiliatedModel = model
        output.reloadData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
