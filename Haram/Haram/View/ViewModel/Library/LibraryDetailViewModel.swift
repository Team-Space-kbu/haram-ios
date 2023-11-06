//
//  LibraryResultsViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import RxSwift
import RxCocoa

protocol LibraryDetailViewModelType {
  var whichRequestBookPath: AnyObserver<Int> { get }
  
  var detailBookInfo: Driver<[LibraryRentalViewModel]> { get }
  var detailMainModel: Driver<LibraryDetailMainViewModel> { get }
  var detailSubModel: Driver<LibraryDetailSubViewModel> { get }
  var detailInfoModel: Driver<[LibraryInfoViewModel]> { get }
  var detailRentalModel: Driver<[LibraryRentalViewModel]> { get }
  var relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class LibraryDetailViewModel: LibraryDetailViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichRequestBookPath: AnyObserver<Int>
  
  let detailBookInfo: Driver<[LibraryRentalViewModel]>
  let detailMainModel: Driver<LibraryDetailMainViewModel>
  let detailSubModel: Driver<LibraryDetailSubViewModel>
  let detailInfoModel: Driver<[LibraryInfoViewModel]>
  let detailRentalModel: Driver<[LibraryRentalViewModel]>
  let relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  let errorMessage: Signal<HaramError>
  
  init() {
    let whichRequestingBookPath = PublishSubject<Int>()
    let currentDetailBookInfo = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentDetailMainModel = BehaviorRelay<LibraryDetailMainViewModel?>(value: nil)
    let currentDetailSubModel = BehaviorRelay<LibraryDetailSubViewModel?>(value: nil)
    let currentDetailInfoModel = BehaviorRelay<[LibraryInfoViewModel]>(value: [])
    let currentDetailRentalModel = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentRelatedBookModel = BehaviorRelay<[LibraryRelatedBookCollectionViewCellModel]>(value: [])
    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let errorMessageRelay = PublishRelay<HaramError>()
    
    whichRequestBookPath = whichRequestingBookPath.asObserver()
    detailBookInfo = currentDetailBookInfo.asDriver()
    detailMainModel = currentDetailMainModel.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
    detailSubModel = currentDetailSubModel.compactMap { $0 }.asDriver(onErrorDriveWith: .empty())
    detailInfoModel = currentDetailInfoModel.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: [])
    detailRentalModel = currentDetailRentalModel.asDriver()
    relatedBookModel = currentRelatedBookModel.asDriver()
    isLoading = isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    errorMessage = errorMessageRelay.filter { $0 == .noEnglishRequest || $0 == .noRequestFromNaver }.asSignal(onErrorSignalWith: .empty())
    
    let shareRequestingBookText = whichRequestingBookPath.share()
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
    
    shareRequestingBookText
      .flatMapLatest(LibraryService.shared.requestBookInfo(text: ))
      .subscribe(onNext: { response in
        
          currentDetailMainModel.accept(LibraryDetailMainViewModel(response: response))
          
          currentDetailSubModel.accept(LibraryDetailSubViewModel(response: response))
          
          currentDetailInfoModel.accept(LibraryDetailInfoViewType.allCases.map { type in
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
        
        isLoadingSubject.onNext(false)
      }, onError: { error in
        guard let error = error as? HaramError else { return }
        errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
    
    shareRequestingBookText
      .flatMapLatest(LibraryService.shared.requestBookLoanStatus(path: ))
      .subscribe(onNext: { response in
        
        currentDetailRentalModel.accept(
          response.keepBooks.keepBooks.map { .init(keepBook: $0) }
        )
        currentRelatedBookModel.accept(
          response.relateBooks.relatedBooks.map { LibraryRelatedBookCollectionViewCellModel(relatedBook: $0) }
        )
        
        isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
