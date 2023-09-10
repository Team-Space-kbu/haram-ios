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
  var detailMainModel: Driver<[LibraryDetailMainViewModel]> { get }
  var detailSubModel: Driver<[LibraryDetailSubViewModel]> { get }
  var detailInfoModel: Driver<[LibraryInfoViewModel]> { get }
  var detailRentalModel: Driver<[LibraryRentalViewModel]> { get }
  var relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryDetailViewModel: LibraryDetailViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichRequestBookPath: AnyObserver<Int>
  
  let detailBookInfo: Driver<[LibraryRentalViewModel]>
  let detailMainModel: Driver<[LibraryDetailMainViewModel]>
  let detailSubModel: Driver<[LibraryDetailSubViewModel]>
  let detailInfoModel: Driver<[LibraryInfoViewModel]>
  let detailRentalModel: Driver<[LibraryRentalViewModel]>
  let relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  
  init() {
    let whichRequestingBookPath = PublishSubject<Int>()
    let currentDetailBookInfo = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentDetailMainModel = BehaviorRelay<[LibraryDetailMainViewModel]>(value: [])
    let currentDetailSubModel = BehaviorRelay<[LibraryDetailSubViewModel]>(value: [])
    let currentDetailInfoModel = BehaviorRelay<[LibraryInfoViewModel]>(value: [])
    let currentDetailRentalModel = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentRelatedBookModel = BehaviorRelay<[LibraryRelatedBookCollectionViewCellModel]>(value: [])
    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    whichRequestBookPath = whichRequestingBookPath.asObserver()
    detailBookInfo = currentDetailBookInfo.asDriver()
    detailMainModel = currentDetailMainModel.asDriver()
    detailSubModel = currentDetailSubModel.asDriver()
    detailInfoModel = currentDetailInfoModel.asDriver()
    detailRentalModel = currentDetailRentalModel.asDriver()
    relatedBookModel = currentRelatedBookModel.asDriver()
    isLoading = isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
    
    let shareRequestingBookText = whichRequestingBookPath.share()
    
    shareRequestingBookText
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
      .flatMapLatest(LibraryService.shared.requestBookInfo(text: ))
      .subscribe(onNext: { result in
        guard case let .success(response) = result else { return }
        currentDetailMainModel.accept([LibraryDetailMainViewModel(
          bookImage: response.thumbnailImage,
          title: response.bookTitle,
          subTitle: response.publisher
        )])
        
        currentDetailSubModel.accept([LibraryDetailSubViewModel(
          title: "책 설명",
          description: response.description
        )])
        
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
              let charToRemove: Character = "\\"
              let discount = response.discount
              let filterDiscount = discount.filter { $0 != charToRemove }
              let trimDiscount = filterDiscount.trimmingCharacters(in: .whitespacesAndNewlines)
              content = trimDiscount != "정보없음" ? filterDiscount + "원" : trimDiscount
          }
          return LibraryInfoViewModel(title: type.title, content: content)
        })
        isLoadingSubject.onNext(false)
      })
      .disposed(by: disposeBag)
        
        shareRequestingBookText
        .do(onNext: { _ in isLoadingSubject.onNext(true) })
        .flatMapLatest(LibraryService.shared.requestBookLoanStatus(path: ))
        .subscribe(onNext: { result in
          // TODO: - 책에 대한 대여정보가 없을 경우에 대한 처리 해야함
          guard case let .success(response) = result else { return }
          currentDetailRentalModel.accept(
            response.keepBooks.keepBooks.map { .init(keepBook: $0) }
          )
          currentRelatedBookModel.accept(
            response.relateBooks.relatedBooks.map { .init(bookImageURL: $0.image) }
          )
          
          isLoadingSubject.onNext(false)
        })
        .disposed(by: disposeBag)
  }
}
