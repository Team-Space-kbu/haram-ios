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
}

final class BibleSearchResultViewModel {
  
  private let disposeBag = DisposeBag()
  private let searchResultContentRelay = PublishRelay<String>()
  
}

extension BibleSearchResultViewModel: BibleSearchResultViewModelType {
  
  func searchBible(request: InquireChapterToBibleRequest) {
    BibleService.shared.inquireChapterToBible(request: request)
      .subscribe(with: self) { owner, responses in
        owner.searchResultContentRelay.accept(responses.toStringWithWhiteSpace)
      }
      .disposed(by: disposeBag)
  }
  
  var searchResultContent: RxCocoa.Driver<String> {
    searchResultContentRelay.asDriver(onErrorDriveWith: .empty())
  }
  
}


