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
  
  var searchResults: Driver<[LibraryResultsCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryResultsViewModel: LibraryResultsViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichSearchText: AnyObserver<String>
  let searchResults:Driver<[LibraryResultsCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  
  init() {
    let whichSearchingText = PublishSubject<String>()
    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let searchBookResults = PublishRelay<[LibraryResultsCollectionViewCellModel]>()
    
    whichSearchText = whichSearchingText.asObserver()
    
    let requestSearchBook = whichSearchingText
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
        .flatMapLatest(LibraryService.shared.searchBook)
        
        requestSearchBook.subscribe(onNext: { result in
          switch result {
          case .success(let response):
            let model = response.map { LibraryResultsCollectionViewCellModel(response: $0) }
            searchBookResults.accept(model)
          case .failure(_):
            searchBookResults.accept([])
          }
          isLoadingSubject.onNext(false)
        })
        .disposed(by: disposeBag)
        
        // Output
        searchResults = searchBookResults
          .asDriver(onErrorDriveWith: .empty())
        isLoading = isLoadingSubject.asDriver(onErrorJustReturn: false)
        }
}
