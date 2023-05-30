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
  
  var newBookModel: Driver<[LibraryCollectionViewCellModel]> { get }
  var bestBookModel: Driver<[LibraryCollectionViewCellModel]> { get }
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let initialData: AnyObserver<Void>
  
  let newBookModel: Driver<[LibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[LibraryCollectionViewCellModel]>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[LibraryCollectionViewCellModel]>(value: [])
    let initializingData = PublishSubject<Void>()
    
    initialData = initializingData.asObserver()
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary.subscribe(onNext: { response in
      currentNewBookModel.accept(response.newBook.map { LibraryCollectionViewCellModel(newBook: $0) })
      currentBestBookModel.accept(response.bestBook.map { LibraryCollectionViewCellModel(bestBook: $0) })
    })
    .disposed(by: disposeBag)
    
    // Output
    newBookModel = currentNewBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    bestBookModel = currentBestBookModel
      .asDriver(onErrorDriveWith: .empty())
  }
}
