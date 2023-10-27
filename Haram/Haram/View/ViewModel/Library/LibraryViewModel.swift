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
  var rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]> { get }
  var bannerImage: Signal<String?> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryViewModel: LibraryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let initialData: AnyObserver<Void>
  
  let newBookModel: Driver<[NewLibraryCollectionViewCellModel]>
  let bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]>
  let rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]>
  let bannerImage: Signal<String?>
  let isLoading: Driver<Bool>
  
  init() {
    
    let currentNewBookModel = BehaviorRelay<[NewLibraryCollectionViewCellModel]>(value: [])
    let currentBestBookModel = BehaviorRelay<[PopularLibraryCollectionViewCellModel]>(value: [])
    let currentRentalBookModel = BehaviorRelay<[RentalLibraryCollectionViewCellModel]>(value: [])
    let initializingData = PublishSubject<Void>()
    let bannerImageRelay = PublishRelay<String?>()
    let isLoadingSubject = PublishSubject<Bool>()
    
    initialData = initializingData.asObserver()
    
    let inquireLibrary = LibraryService.shared.inquireLibrary()
    
    inquireLibrary
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
        .subscribe(onNext: { result in
          guard case let .success(response) = result else { return }
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
        
        bannerImage = bannerImageRelay.asSignal()
        
        isLoading = isLoadingSubject
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: false)
        }
}
