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
}

final class BibleViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let todayBibleWordListRelay = BehaviorRelay<[String]>(value: [])
  private let todayPrayListRelay = BehaviorRelay<[TodayPrayCollectionViewCellModel]>(value: [])
  
  init() {
    inquireTodayBibleWord()
  }
  
  private func inquireTodayBibleWord() {
    let tryInquireTodayBibleWord = BibleService.shared.inquireTodayWords(request: .init(bibleType: .rt)).share()
    
    let failureInquireTodayBibleWord = tryInquireTodayBibleWord.compactMap { result -> HaramError? in
      guard case let .failure(error) = result else { return nil }
      return error
    }
    
    let successInquireTodayBibleWord = tryInquireTodayBibleWord.compactMap { result -> [InquireTodayWordsResponse]? in
      guard case let .success(response) = result else { return nil }
      return response
    }
    
    successInquireTodayBibleWord
      .compactMap { $0.first?.content }
      .subscribe(with: self) { owner, content in
        owner.todayBibleWordListRelay.accept([content])
      }
      .disposed(by: disposeBag)
  }
}

extension BibleViewModel: BibleViewModelType {
  var todayPrayList: RxCocoa.Driver<[TodayPrayCollectionViewCellModel]> {
    todayPrayListRelay.asDriver()
  }
  
  var todayBibleWordList: Driver<[String]> {
    todayBibleWordListRelay.asDriver()
  }
}
