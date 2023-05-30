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
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let initialData: AnyObserver<Void>
  let whichSearchText: AnyObserver<String>
  
  let newBookModel: Driver<[LibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[LibraryCollectionViewCellModel]>
  let searchResults: Driver<[LibraryResultsCollectionViewCellModel]>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let searchBookResults = BehaviorRelay<[LibraryResultsCollectionViewCellModel]>(value: [])
    let initializingData = PublishSubject<Void>()
    let whichSearchingText = PublishSubject<String>()
    
    initialData = initializingData.asObserver()
    whichSearchText = whichSearchingText.asObserver()
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary.subscribe(onNext: { response in
      currentNewBookModel.accept(response.newBook.map { LibraryCollectionViewCellModel(newBook: $0) })
      currentBestBookModel.accept(response.bestBook.map { LibraryCollectionViewCellModel(bestBook: $0) })
    })
    .disposed(by: disposeBag)
    
    let requestSearchBook = whichSearchingText
//      .filter { !$0.isEmpty }
      .flatMapLatest(LibraryService.shared.searchBook)
    
    requestSearchBook.subscribe(onNext: { response in
      let model = response.map { LibraryResultsCollectionViewCellModel(response: $0) }
      searchBookResults.accept(model)
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
