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
    let tryInquireTodayBibleWord = BibleService.shared.inquireTodayWords(request: .init(bibleType: .RT)).share()
    
    let resultInquireTodayBibleWord = tryInquireTodayBibleWord.compactMap { result -> String? in
      switch result {
      case .success(let response):
        return response.first?.content
      case .failure(let error):
        return error.description
      }
    }
    
    resultInquireTodayBibleWord
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
