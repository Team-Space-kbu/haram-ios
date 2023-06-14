//
//  LibraryResultsViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import RxSwift
import RxCocoa

protocol LibraryDetailViewModelType {
  var whichRequestBookText: AnyObserver<String> { get }
  
  var detailBookInfo: Driver<[LibraryRentalViewModel]> { get }
  var detailMainModel: Driver<LibraryDetailMainViewModel> { get }
  var detailSubModel: Driver<LibraryDetailSubViewModel> { get }
  var detailInfoModel: Driver<[LibraryInfoViewModel]> { get }
  var detailRentalModel: Driver<[LibraryRentalViewModel]> { get }
}

final class LibraryDetailViewModel: LibraryDetailViewModelType {
  
  private let disposeBag = DisposeBag()
  
  let whichRequestBookText: AnyObserver<String>
  
  let detailBookInfo: Driver<[LibraryRentalViewModel]>
  let detailMainModel: Driver<LibraryDetailMainViewModel>
  let detailSubModel: Driver<LibraryDetailSubViewModel>
  let detailInfoModel: Driver<[LibraryInfoViewModel]>
  let detailRentalModel: Driver<[LibraryRentalViewModel]>
  
  init() {
    let whichRequestingBookText = PublishSubject<String>()
    let currentDetailBookInfo = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    let currentDetailMainModel = PublishRelay<LibraryDetailMainViewModel>()
    let currentDetailSubModel = PublishRelay<LibraryDetailSubViewModel>()
    let currentDetailInfoModel = BehaviorRelay<[LibraryInfoViewModel]>(value: [])
    let currentDetailRentalModel = BehaviorRelay<[LibraryRentalViewModel]>(value: [])
    
    whichRequestBookText = whichRequestingBookText.asObserver()
    detailBookInfo = currentDetailBookInfo.asDriver()
    detailMainModel = currentDetailMainModel.asDriver(onErrorJustReturn: .init(bookImage: "", title: "", subTitle: ""))
    detailSubModel = currentDetailSubModel.asDriver(onErrorJustReturn: .init(title: "", description: ""))
    detailInfoModel = currentDetailInfoModel.asDriver()
    detailRentalModel = currentDetailRentalModel.asDriver()
    
    whichRequestingBookText
      .flatMapLatest(LibraryService.shared.requestBookInfo(text: ))
      .subscribe(onNext: { response in
        currentDetailMainModel.accept(LibraryDetailMainViewModel(bookImage: response.bookInfoRes.image, title: response.bookInfoRes.title, subTitle: response.bookInfoRes.publisher))
        
        currentDetailSubModel.accept(LibraryDetailSubViewModel(title: "책 설명", description: response.bookInfoRes.description))
        
        currentDetailInfoModel.accept(LibraryDetailInfoViewType.allCases.map { type in
          switch type {
          case .author:
            return LibraryInfoViewModel(title: type.title, content: response.bookInfoRes.author)
          case .publisher:
            return LibraryInfoViewModel(title: type.title, content: response.bookInfoRes.publisher)
          case .publishDate:
            return LibraryInfoViewModel(title: type.title, content: response.bookInfoRes.pubdate)
          case .discount:
            return LibraryInfoViewModel(title: type.title, content: response.bookInfoRes.discount)
          }
        })
        
        currentDetailRentalModel.accept(
          response.bookKeep.map { LibraryRentalViewModel(
            register: $0.register,
            number: $0.number,
            holdingInstitution: $0.holdingInstitution,
            loanStatus: $0.loanStatus
          ) }
        )
      })
      .disposed(by: disposeBag)
  }
}
