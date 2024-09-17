//
//  BookDetailViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import Foundation
import RxSwift
import RxCocoa

final class BookDetailViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let payload: Payload
  private let dependency: Dependency
  
  private(set) var mainModel: LibraryDetailMainViewModel?
  private(set) var subModel: LibraryDetailSubViewModel?
  private(set) var rentalModel: [LibraryRentalViewModel] = []
  private(set) var bookInfoModel: [LibraryInfoViewModel] = []
  private(set) var relatedBookModel: [LibraryCollectionViewCellModel] = []
  
  struct Payload {
    let path: Int
  }
  
  struct Dependency {
    let libraryRepository: LibraryRepository
    let coordinator: BookDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapRecommendedBookCell: Observable<IndexPath>
    let didTapBookThumbnail: Observable<Void>
  }
  
  struct Output {
    let reloadData   = PublishRelay<Void>()
    let isLoading    = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestBookInfo(output: output)
        owner.requestBookLoanStatus(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapBookThumbnail
      .subscribe(with: self) { owner, _ in
        guard let bookThumbnailURL = owner.mainModel?.bookImageURL else {
          owner.dependency.coordinator.showAlert(message: "해당 이미지는 확대할 수 없습니다")
          return
        }
        owner.dependency.coordinator.showZoomImageViewController(imageURL: bookThumbnailURL)
      }
      .disposed(by: disposeBag)
    
    input.didTapRecommendedBookCell
      .subscribe(with: self) { owner, indexPath in
        let path = owner.relatedBookModel[indexPath.row].path
        owner.dependency.coordinator.showLibraryDetailViewController(path: path)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension BookDetailViewModel {
  
  func requestBookInfo(output: Output) {
    
    output.isLoading.accept(true)
    
    dependency.libraryRepository.requestBookInfo(text: payload.path)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.mainModel = LibraryDetailMainViewModel(response: response)
        owner.subModel = LibraryDetailSubViewModel(response: response)
        owner.bookInfoModel = LibraryDetailInfoViewType.allCases.map { type in
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
        }
        output.reloadData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func requestBookLoanStatus(output: Output) {
    dependency.libraryRepository.requestBookLoanStatus(path: payload.path)
      .subscribe(with: self, onSuccess: { owner, response in
        owner.rentalModel = response.keepBooks.keepBooks.map { .init(keepBook: $0) }
        owner.relatedBookModel = response.relateBooks.relatedBooks.map { LibraryCollectionViewCellModel(relatedBook: $0) }
        output.reloadData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
