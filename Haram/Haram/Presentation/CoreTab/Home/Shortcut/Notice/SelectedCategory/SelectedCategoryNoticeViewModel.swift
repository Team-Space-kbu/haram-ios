//
//  SelectedCategoryNoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SelectedCategoryNoticeViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  let payload: Payload
  
  private(set) var noticeModel: [NoticeCollectionViewCellModel] = []
  
  private let currentPage = BehaviorRelay<Int>(value: 1)
  private let isLastPage         = BehaviorRelay<Int>(value: 1)
  private let isLoading     = BehaviorRelay<Bool>(value: false)
  
  struct Dependency {
    let noticeRepository: NoticeRepository
    let coordinator: SelectedCategoryCoordinator
  }
  
  struct Payload {
    let noticeType: NoticeType
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let fetchMoreDatas = PublishSubject<Void>()
    let didTapBackButton: Observable<Void>
    let didTapNoticeCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let noticeCollectionViewCellModel = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.inquireNoticeList(output: output)
      }
      .disposed(by: disposeBag)
    
    input.fetchMoreDatas
      .filter { [weak self] _ in
        guard let self = self else { return false }
        return self.currentPage.value < self.isLastPage.value && !self.isLoading.value
      }
      .subscribe(with: self) { owner, _ in
        let currentPage = owner.currentPage.value
        owner.currentPage.accept(currentPage + 1)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapNoticeCell
      .subscribe(with: self) { owner, indexPath in
        owner.dependency.coordinator.showNoticeDetailViewController(path: owner.noticeModel[indexPath.row].path)
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  private func inquireNoticeList(output: Output) {
    currentPage
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.isLoading.accept(true)
      })
      .flatMapLatest { owner, page in
        return owner.dependency.noticeRepository.inquireNoticeInfo(
          request: .init(
            type: owner.payload.noticeType,
            page: page
          )
        )
      }
      .subscribe(with: self, onNext: { owner, response in
        var noticeModel = output.noticeCollectionViewCellModel.value
        noticeModel.append(contentsOf: response.notices.map {
          
          if let iso8607Date = DateformatterFactory.dateForISO8601UTC.date(from: $0.regDate) {
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: DateformatterFactory.dateWithHypen.string(from: iso8607Date) + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path)
          } else {
            return NoticeCollectionViewCellModel(
              title: $0.title,
              description: $0.regDate + " | " + $0.name,
              noticeType: $0.loopnum,
              path: $0.path)
          }
        })
        owner.noticeModel = noticeModel
        output.noticeCollectionViewCellModel.accept(noticeModel)
        
        owner.isLoading.accept(false)
        owner.isLastPage.accept(Int(response.end)!)
      }, onError: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  } 
}
