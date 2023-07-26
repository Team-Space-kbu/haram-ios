//
//  LibraryResultsViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import RxSwift
import RxCocoa

protocol LibraryDetailViewModelType {
  var whichRequestBookText: AnyObserver<Int> { get }
  
  var detailBookInfo: Driver<[LibraryRentalViewModel]> { get }
  var detailMainModel: Driver<LibraryDetailMainViewModel> { get }
  var detailSubModel: Driver<LibraryDetailSubViewModel> { get }
  var detailInfoModel: Driver<[LibraryInfoViewModel]> { get }
  var detailRentalModel: Driver<[LibraryRentalViewModel]> { get }
  var relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
}

final class LibraryDetailViewModel: LibraryDetailViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichRequestBookText: AnyObserver<Int>
  
  let detailBookInfo: Driver<[LibraryRentalViewModel]>
  let detailMainModel: Driver<LibraryDetailMainViewModel>
  let detailSubModel: Driver<LibraryDetailSubViewModel>
  let detailInfoModel: Driver<[LibraryInfoViewModel]>
  let detailRentalModel: Driver<[LibraryRentalViewModel]>
  let relatedBookModel: Driver<[LibraryRelatedBookCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  
  init() {
    let whichRequestingBookText = PublishSubject<Int>()
    let currentDetailBookInfo = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentDetailMainModel = PublishRelay<LibraryDetailMainViewModel>()
    let currentDetailSubModel = PublishRelay<LibraryDetailSubViewModel>()
    let currentDetailInfoModel = BehaviorRelay<[LibraryInfoViewModel]>(value: [])
    let currentDetailRentalModel = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentRelatedBookModel = BehaviorRelay<[LibraryRelatedBookCollectionViewCellModel]>(value: [])
    let isLoadingSubject = BehaviorSubject<Bool>(value: true)
    
    whichRequestBookText = whichRequestingBookText.asObserver()
    detailBookInfo = currentDetailBookInfo.asDriver()
    detailMainModel = currentDetailMainModel.asDriver(onErrorJustReturn: .init(bookImage: "", title: "", subTitle: ""))
    detailSubModel = currentDetailSubModel.asDriver(onErrorJustReturn: .init(title: "", description: ""))
    detailInfoModel = currentDetailInfoModel.asDriver()
    detailRentalModel = currentDetailRentalModel.asDriver()
    relatedBookModel = currentRelatedBookModel.asDriver()
    isLoading = isLoadingSubject.asDriver(onErrorJustReturn: false)
    
    whichRequestingBookText
      .do(onNext: { _ in isLoadingSubject.onNext(true) })
      .flatMapLatest(LibraryService.shared.requestBookInfo(text: ))
      .subscribe(onNext: { response in
        currentDetailMainModel.accept(LibraryDetailMainViewModel(bookImage: response.image, title: response.title, subTitle: response.publisher))
        
        currentDetailSubModel.accept(LibraryDetailSubViewModel(title: "책 설명", description: response.description))
        
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
            content = response.discount
          }
          return LibraryInfoViewModel(title: type.title, content: content)
        })
        isLoadingSubject.onNext(false)
      }, onError: { error in
        isLoadingSubject.onNext(false)
        guard let error = error as? HaramError,
              error == HaramError.naverError else { return }
        print("네이버오류 ")
      })
      .disposed(by: disposeBag)
  }
}
