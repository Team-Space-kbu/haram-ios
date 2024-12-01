//
//  MoreCategoryViewModel.swift
//  Haram
//
//  Created by 이건준 on 11/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MoreCategoryViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  let payload: Payload
  
  private(set) var noticeModel: [NoticeCollectionViewCellModel] = []
  
  private let currentPageSubject = BehaviorRelay<Int>(value: 1)
  private let isLastPage         = BehaviorRelay<Int>(value: 1)
  private let isLoadingRelay     = BehaviorRelay<Bool>(value: false)
  
  struct Dependency {
    let noticeRepository: NoticeRepository
    let coordinator: MoreCategoryCoordinator
  }
  
  struct Payload {
    let noticeType: NoticeType
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let fetchMoreDatas = PublishSubject<Void>()
    let didTapBackButton: Observable<Void>
    let didTapNoticeCell: Observable<IndexPath>
  }
  
  struct Output {
    let noticeCollectionViewCellModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
    let errorMessageRelay = PublishRelay<HaramError>()
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
    
    input.fetchMoreDatas
      .filter { [weak self] _ in
        guard let self = self else { return false }
        return self.currentPageSubject.value < self.isLastPage.value && !self.isLoadingRelay.value
      }
      .subscribe(with: self) { owner, _ in
        let currentPage = owner.currentPageSubject.value
        owner.currentPageSubject.accept(currentPage + 1)
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
    currentPageSubject
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.isLoadingRelay.accept(true)
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
        var noticeModel = output.noticeCollectionViewCellModelRelay.value
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
        output.noticeCollectionViewCellModelRelay.accept(noticeModel)
        
        owner.isLoadingRelay.accept(false)
        owner.isLastPage.accept(Int(response.end)!)
      }, onError: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

