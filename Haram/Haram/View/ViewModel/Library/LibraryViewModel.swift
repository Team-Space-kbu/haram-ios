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
  
  var newBookModel: Driver<[NewLibraryCollectionViewCellModel]> { get }
  var bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let initialData: AnyObserver<Void>
  
  let newBookModel: Driver<[NewLibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[NewLibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[PopularLibraryCollectionViewCellModel]>(value: [])
    let initializingData = PublishSubject<Void>()
    let isLoadingSubject = BehaviorSubject<Bool>(value: true)
    
    initialData = initializingData.asObserver()
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
        .subscribe(onNext: { result in
          guard case let .success(response) = result else { return }
          currentNewBookModel.accept(response.newBook.map { NewLibraryCollectionViewCellModel(newBook: $0) })
          currentBestBookModel.accept(response.bestBook.map { PopularLibraryCollectionViewCellModel(bestBook: $0) })
          isLoadingSubject.onNext(false)
        })
        .disposed(by: disposeBag)
        
        // Output
        newBookModel = currentNewBookModel
        .asDriver(onErrorDriveWith: .empty())
        
        bestBookModel = currentBestBookModel
        .asDriver(onErrorDriveWith: .empty())
        
        isLoading = isLoadingSubject
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: false)
        }
}
