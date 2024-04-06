//
//  BibleSearchResultViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/09/12.
//

import RxSwift
import RxCocoa

protocol BibleSearchResultViewModelType {
  func searchBible(request: InquireChapterToBibleRequest)
  
  var searchResultContent: Driver<String> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class BibleSearchResultViewModel {
  
  private let bibleRepository: BibleRepository
  private let disposeBag = DisposeBag()
  private let searchResultContentRelay = PublishRelay<String>()
  private let errorMessageRelay        = BehaviorRelay<HaramError?>(value: nil)
  
  init(bibleRepository: BibleRepository = BibleRepositoryImpl()) {
    self.bibleRepository = bibleRepository
  }
  
}

extension BibleSearchResultViewModel: BibleSearchResultViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  
  func searchBible(request: InquireChapterToBibleRequest) {
    bibleRepository.inquireChapterToBible(request: request)
      .subscribe(with: self, onSuccess: { owner, responses in
        owner.searchResultContentRelay.accept(responses.toStringWithWhiteSpace)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var searchResultContent: RxCocoa.Driver<String> {
    searchResultContentRelay.asDriver(onErrorDriveWith: .empty())
  }
  
}


