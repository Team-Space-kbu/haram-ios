//
//  BibleViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift
import RxCocoa


protocol BibleViewModelType {
  var todayBibleWordList: Driver<[String]> { get }
  var todayPrayList: Driver<[TodayPrayCollectionViewCellModel]> { get }
  var bibleMainNotice: Driver<[BibleNoticeCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class BibleViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = BehaviorRelay<[String]>(value: [])
  private let todayPrayListRelay = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  private let bibleMainNoticeRelay = BehaviorRelay<[BibleNoticeCollectionViewCellModel]>(value: [])
  private let isLoadingSubject = PublishSubject<Bool>()
  
  init() {
    inquireTodayBibleWord()
    inquireBibleMainNotice()
  }
  
  private func inquireTodayBibleWord() {
    let tryInquireTodayBibleWord = BibleService.shared.inquireTodayWords(request: .init(bibleType: .RT))
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    tryInquireTodayBibleWord
      .subscribe(with: self, onSuccess: { owner, response in
        guard let content = response.first?.content else { return }
        owner.todayBibleWordListRelay.accept([content])
        owner.isLoadingSubject.onNext(false)
      }, onFailure:  { owner, error in
        guard let error = error as? HaramError else { return }
        owner.todayBibleWordListRelay.accept([error.description!])
        owner.isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
    
    
  }
  
  private func inquireBibleMainNotice() {
    let inquireBibleMainNotice = BibleService.shared.inquireBibleMainNotice()
      .do(onSuccess: { [weak self] _ in
        guard let self = self else { return }
        self.isLoadingSubject.onNext(true)
      })
    
    inquireBibleMainNotice
      .subscribe(with: self) { owner, response in
        owner.bibleMainNoticeRelay.accept([BibleNoticeCollectionViewCellModel(response: response)])
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
  var bibleMainNotice: RxCocoa.Driver<[BibleNoticeCollectionViewCellModel]> {
    bibleMainNoticeRelay.asDriver()
  }
  
  
  var todayPrayList: RxCocoa.Driver<[TodayPrayCollectionViewCellModel]> {
    todayPrayListRelay.asDriver()
  }
  
  var todayBibleWordList: Driver<[String]> {
    todayBibleWordListRelay.asDriver()
  }
}
