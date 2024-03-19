//
//  BibleViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift
import RxCocoa


protocol BibleViewModelType {
  var todayBibleWordList: Driver<[TodayBibleWordCollectionViewCellModel]> { get }
  var todayPrayList: Driver<[TodayPrayCollectionViewCellModel]> { get }
  var bibleMainNotice: Driver<[BibleNoticeCollectionViewCellModel]> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class BibleViewModel {
  
  private let bibleRepository: BibleRepository
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = PublishRelay<[TodayBibleWordCollectionViewCellModel]>()
  private let todayPrayListRelay      = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  private let bibleMainNoticeRelay    = PublishRelay<[BibleNoticeCollectionViewCellModel]>()
  private let errorMessageRelay       = BehaviorRelay<HaramError?>(value: nil)
  
  init(bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.bibleRepository = bibleRepository
    inquireBibleHomeInfo()
  }
  
  private func inquireBibleHomeInfo() {
    let tryInquireBibleHomeInfo = bibleRepository.inquireBibleHomeInfo()
    
    tryInquireBibleHomeInfo
      .subscribe(with: self, onSuccess: { owner, homeInfo in
        let bibleVerse = homeInfo.bibleRandomVerse
        let content = bibleVerse.content
        owner.todayBibleWordListRelay.accept([
          TodayBibleWordCollectionViewCellModel(
            todayBibleWord: content,
            todayBibleBookName: bibleVerse.bookName + ", \(bibleVerse.chapter)장 \(bibleVerse.verse)절"
          )
        ])
        owner.bibleMainNoticeRelay.accept(homeInfo.bibleNoticeResponses.map { BibleNoticeCollectionViewCellModel(response: $0) })
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  

  var bibleMainNotice: RxCocoa.Driver<[BibleNoticeCollectionViewCellModel]> {
    bibleMainNoticeRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  
  var todayPrayList: RxCocoa.Driver<[TodayPrayCollectionViewCellModel]> {
    todayPrayListRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var todayBibleWordList: Driver<[TodayBibleWordCollectionViewCellModel]> {
    todayBibleWordListRelay.asDriver(onErrorDriveWith: .empty())
  }
}
