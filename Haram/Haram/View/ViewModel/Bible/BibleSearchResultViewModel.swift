//
//  BibleSearchResultViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/09/12.
//

import RxSwift
import RxCocoa

protocol BibleSearchResultViewModelType {
  var whichRequestForSearch: AnyObserver<InquireChapterToBibleRequest> { get }
  
  var searchResultContent: Driver<String> { get }
}

final class BibleSearchResultViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let requestTypeForSearchSubject = PublishSubject<InquireChapterToBibleRequest>()
  private let searchResultContentRelay    = PublishRelay<String>()
  
  init() {
    inquireChapterToBible()
  }
  
  private func inquireChapterToBible() {
    let tryInquireChapterToBible = requestTypeForSearchSubject
      .flatMapLatest(BibleService.shared.inquireChapterToBible(request: ))
    
    tryInquireChapterToBible
      .subscribe(with: self) { owner, responses in
        owner.searchResultContentRelay.accept(responses.toStringWithWhiteSpace)
      }
      .disposed(by: disposeBag)
  }
  
}

extension BibleSearchResultViewModel: BibleSearchResultViewModelType {
  var searchResultContent: RxCocoa.Driver<String> {
    searchResultContentRelay.asDriver(onErrorDriveWith: .empty())
  }
  
  var whichRequestForSearch: AnyObserver<InquireChapterToBibleRequest> {
    requestTypeForSearchSubject.asObserver()
  }
}


