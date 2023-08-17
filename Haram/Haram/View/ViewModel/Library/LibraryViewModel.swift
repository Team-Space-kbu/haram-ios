//
//  LibraryViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import RxSwift
import RxCocoa

protocol LibraryViewModelType {
  var initialData: AnyObserver<Void> { get }
  var whichSearchText: AnyObserver<String> { get }
  
  var newBookModel: Driver<[LibraryCollectionViewCellModel]> { get }
  var bestBookModel: Driver<[LibraryCollectionViewCellModel]> { get }
  var searchResults:Driver<[LibraryResultsCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let initialData: AnyObserver<Void>
  let whichSearchText: AnyObserver<String>
  
  let newBookModel: Driver<[LibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[LibraryCollectionViewCellModel]>
  let searchResults: Driver<[LibraryResultsCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let searchBookResults = PublishRelay<[LibraryResultsCollectionViewCellModel]>()
    let initializingData = PublishSubject<Void>()
    let whichSearchingText = PublishSubject<String>()
    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    initialData = initializingData.asObserver()
    whichSearchText = whichSearchingText.asObserver()
    isLoading = isLoadingSubject.asDriver(onErrorJustReturn: false)
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary.subscribe(onNext: { result in
      guard case let .success(response) = result else { return }
      currentNewBookModel.accept(response.newBook.map { LibraryCollectionViewCellModel(newBook: $0) })
      currentBestBookModel.accept(response.bestBook.map { LibraryCollectionViewCellModel(bestBook: $0) })
    })
    .disposed(by: disposeBag)
    
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
    newBookModel = currentNewBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    bestBookModel = currentBestBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    searchResults = searchBookResults
      .asDriver(onErrorDriveWith: .empty())
  }
}
