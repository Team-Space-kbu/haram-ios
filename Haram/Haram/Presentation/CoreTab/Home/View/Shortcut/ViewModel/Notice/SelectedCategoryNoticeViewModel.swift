//
//  SelectedCategoryNoticeViewModel.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import RxSwift
import RxCocoa

protocol SelectedCategoryNoticeViewModelType {
  var fetchMoreDatas: AnyObserver<Void> { get }
  var noticeCollectionViewCellModel: Driver<[NoticeCollectionViewCellModel]> { get }
  var errorMessage: Signal<HaramError> { get }
  
  var noticeType: NoticeType { get }
}

final class SelectedCategoryNoticeViewModel {
  
  private let disposeBag = DisposeBag()
  private let noticeRepository: NoticeRepository
  
  private let noticeCollectionViewCellModelRelay = BehaviorRelay<[NoticeCollectionViewCellModel]>(value: [])
  private let currentPageSubject = BehaviorRelay<Int>(value: 1)
  private let fetchingDatas      = PublishSubject<Void>()
  private let isLastPage         = BehaviorRelay<Int>(value: 1)
  private let isLoadingRelay     = BehaviorRelay<Bool>(value: false)
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  
  let noticeType: NoticeType
  
  init(noticeType: NoticeType, noticeRepository: NoticeRepository = NoticeRepositoryImpl()) {
    self.noticeRepository = noticeRepository
    self.noticeType = noticeType
    
    inquireNoticeList()
    
    fetchingDatas
      .filter { [weak self] _ in
        guard let self = self else { return false }
        return self.currentPageSubject.value < self.isLastPage.value && !self.isLoadingRelay.value
      }
      .subscribe(with: self) { owner, _ in
        let currentPage = owner.currentPageSubject.value
        owner.currentPageSubject.accept(currentPage + 1)
      }
      .disposed(by: disposeBag)
  }
  
  private func inquireNoticeList() {
    
      currentPageSubject
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.isLoadingRelay.accept(true)
      })
      .flatMapLatest { owner, page in
        
        return owner.noticeRepository.inquireNoticeInfo(
          request: .init(
            type: owner.noticeType,
            page: page
          )
        )
      }
      .subscribe(with: self, onNext: { owner, response in
        
        var noticeModel = owner.noticeCollectionViewCellModelRelay.value
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
        
        owner.noticeCollectionViewCellModelRelay.accept(noticeModel)
        
        owner.isLoadingRelay.accept(false)
        owner.isLastPage.accept(Int(response.end)!)
      }, onError: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
}

extension SelectedCategoryNoticeViewModel: SelectedCategoryNoticeViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var fetchMoreDatas: RxSwift.AnyObserver<Void> {
    fetchingDatas.asObserver()
  }

  var noticeCollectionViewCellModel: RxCocoa.Driver<[NoticeCollectionViewCellModel]> {
    noticeCollectionViewCellModelRelay
      .filter { !$0.isEmpty }
      .asDriver(onErrorJustReturn: [])
  }
}
