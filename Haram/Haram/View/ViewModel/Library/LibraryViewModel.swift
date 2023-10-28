//
//  LibraryViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Foundation

import RxSwift
import RxCocoa

protocol LibraryViewModelType {
  var newBookModel: Driver<[NewLibraryCollectionViewCellModel]> { get }
  var bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]> { get }
  var rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]> { get }
  var bannerImage: Signal<URL?> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  
  let newBookModel: Driver<[NewLibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]>
  let rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]>
  let bannerImage: Signal<URL?>
  let isLoading: Driver<Bool>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[NewLibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[PopularLibraryCollectionViewCellModel]>(value: [])
    let currentRentalBookModel = BehaviorRelay<[RentalLibraryCollectionViewCellModel]>(value: [])
    let bannerImageRelay = PublishRelay<String?>()
    let isLoadingSubject = PublishSubject<Bool>()
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary
      .do(onSuccess: { _ in isLoadingSubject.onNext(true) })
      .subscribe(onSuccess: { response in
        currentNewBookModel.accept(response.newBook.map { NewLibraryCollectionViewCellModel(bookInfo: $0) })
        currentBestBookModel.accept(response.bestBook.map { PopularLibraryCollectionViewCellModel(bookInfo: $0) })
        currentRentalBookModel.accept(response.rentalBook.map {
          RentalLibraryCollectionViewCellModel(bookInfo: $0) })
        bannerImageRelay.accept(response.image.first)
        
        isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
    
    // Output
    newBookModel = currentNewBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    bestBookModel = currentBestBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    rentalBookModel = currentRentalBookModel
      .asDriver(onErrorDriveWith: .empty())
    
    bannerImage = bannerImageRelay
      .compactMap { $0 }
      .map { URL(string: $0) }
      .asSignal(onErrorJustReturn: nil)
    
    isLoading = isLoadingSubject
      .asDriver(onErrorJustReturn: false)
  }
}
