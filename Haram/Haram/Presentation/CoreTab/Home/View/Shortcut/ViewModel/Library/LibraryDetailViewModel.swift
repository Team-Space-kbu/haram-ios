//
//  LibraryResultsViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import RxSwift
import RxCocoa

protocol LibraryDetailViewModelType {
  
  func requestBookInfo(path: Int)
  
  var detailBookInfo: Driver<[LibraryRentalViewModel]> { get }
  var detailMainModel: Driver<LibraryDetailMainViewModel> { get }
  var detailSubModel: Driver<LibraryDetailSubViewModel> { get }
  var detailInfoModel: Driver<[LibraryInfoViewModel]> { get }
  var detailRentalModel: Driver<[LibraryRentalViewModel]> { get }
  var relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class LibraryDetailViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentDetailBookInfo    = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
  private let currentDetailMainModel   = BehaviorRelay<LibraryDetailMainViewModel?>(value: nil)
  private let currentDetailSubModel    = BehaviorRelay<LibraryDetailSubViewModel?>(value: nil)
  private let currentDetailInfoModel   = BehaviorRelay<[LibraryInfoViewModel]>(value: [])
  private let currentDetailRentalModel = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
  private let currentRelatedBookModel  = BehaviorRelay<[LibraryRelatedBookCollectionViewCellModel]>(value: [])
  private let isLoadingSubject         = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay        = PublishRelay<HaramError>()
  
}

extension LibraryDetailViewModel: LibraryDetailViewModelType {
  
  func requestBookInfo(path: Int) {
    
    self.isLoadingSubject.onNext(true)
    
    LibraryService.shared.requestBookInfo(text: path)
      .subscribe(with: self, onSuccess: { owner, response in
        
        owner.currentDetailMainModel.accept(LibraryDetailMainViewModel(response: response))
        owner.currentDetailSubModel.accept(LibraryDetailSubViewModel(response: response))
        owner.currentDetailInfoModel.accept(LibraryDetailInfoViewType.allCases.map { type in
          let content: String
          switch type {
          case .author:
            content = response.author
          case .publisher:
            content = response.publisher
          case .publishDate:
            content = response.pubDate
          case .discount:
            
            /// 외부 API를 통해 받아온 데이터에 \\를 필터링하는 로직
            let charToRemove: Character = "\\"
            let discount = response.discount
            let filterDiscount = discount.filter { $0 != charToRemove }
            let trimDiscount = filterDiscount.trimmingCharacters(in: .whitespacesAndNewlines)
            content = trimDiscount != "정보없음" ? filterDiscount + "원" : trimDiscount
          }
          return LibraryInfoViewModel(title: type.title, content: content)
        })
        
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
    
    LibraryService.shared.requestBookLoanStatus(path: path)
      .subscribe(with: self) { owner, response in
        
        owner.currentDetailRentalModel.accept(
          response.keepBooks.keepBooks.map { .init(keepBook: $0) }
        )
        owner.currentRelatedBookModel.accept(
          response.relateBooks.relatedBooks.map { LibraryRelatedBookCollectionViewCellModel(relatedBook: $0) }
        )
        
      }
      .disposed(by: disposeBag)
    
    self.isLoadingSubject.onNext(false)
    
  }
  
  var detailBookInfo: RxCocoa.Driver<[LibraryRentalViewModel]> {
    currentDetailBookInfo.asDriver()
  }
  
  var detailMainModel: RxCocoa.Driver<LibraryDetailMainViewModel> {
    currentDetailMainModel.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
  }
  
  var detailSubModel: RxCocoa.Driver<LibraryDetailSubViewModel> {
    currentDetailSubModel.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
  }
  
  var detailInfoModel: RxCocoa.Driver<[LibraryInfoViewModel]> {
    currentDetailInfoModel.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: [])
  }
  
  var detailRentalModel: RxCocoa.Driver<[LibraryRentalViewModel]> {
    currentDetailRentalModel.asDriver()
  }
  
  var relatedBookModel: RxCocoa.Driver<[LibraryRelatedBookCollectionViewCellModel]> {
    currentRelatedBookModel.asDriver()
  }
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.filter { $0 == .noEnglishRequest || $0 == .noRequestFromNaver }.asSignal(onErrorSignalWith: .empty())
  }
  
  
}
