//
//  LibraryResultsViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/09/04.
//

import RxSwift
import RxCocoa

protocol LibraryResultsViewModelType {
  var whichSearchText: AnyObserver<String> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  var searchResults: Driver<[LibraryResultsCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryResultsViewModel: LibraryResultsViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichSearchText: AnyObserver<String>
  let searchResults:Driver<[LibraryResultsCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  let fetchMoreDatas: AnyObserver<Void>
  
  init() {
    let whichSearchingText = PublishSubject<String>()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let searchBookResults = BehaviorRelay<[LibraryResultsCollectionViewCellModel]>(value: [])
    let currentPageSubject = BehaviorRelay<Int>(value: 1)
    let fetchingDatas = PublishSubject<Void>()
    let isLastPage = BehaviorRelay<Int>(value: 1)
    
    whichSearchText = whichSearchingText.asObserver()
    fetchMoreDatas = fetchingDatas.asObserver()
    
    let requestSearchBook = Observable.combineLatest(
      whichSearchingText,
      currentPageSubject
    )
      .do(onNext: { _ in isLoadingRelay.accept(true) })
      .flatMapLatest(LibraryService.shared.searchBook)
    
    requestSearchBook.subscribe(onNext: { response in
      
      
      let model = response.result.map {
        LibraryResultsCollectionViewCellModel(result: $0)
      }
      var currentResultModel = searchBookResults.value
      currentResultModel.append(contentsOf: model)
      searchBookResults.accept(currentResultModel)
      isLastPage.accept(response.end)
      
      
      isLoadingRelay.accept(false)
    }, onError: { _ in
      searchBookResults.accept([])
      isLoadingRelay.accept(false)
    })
    .disposed(by: disposeBag)
    
    fetchingDatas
      .filter { _ in currentPageSubject.value < isLastPage.value && !isLoadingRelay.value }
      .subscribe(onNext: { _ in
        let currentPage = currentPageSubject.value
        currentPageSubject.accept(currentPage + 1)
      })
      .disposed(by: disposeBag)
    
    // Output
    searchResults = searchBookResults
      .skip(1)
      .asDriver(onErrorDriveWith: .empty())
    
    isLoading = isLoadingRelay
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
