//
//  BookListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Foundation

import RxSwift
import RxCocoa

final class BookListViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  
  private(set) var newBookModel: [LibraryCollectionViewCellModel] = []
  private(set) var bestBookModel: [LibraryCollectionViewCellModel] = []
  private(set) var rentalBookModel: [LibraryCollectionViewCellModel] = []
  private(set) var bannerModel: [URL?] = []
  
  struct Payload {
    
  }
  
  struct Dependency {
    let libraryRepository: LibraryRepository
    let coordinator: BookListCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapLibraryCell: Observable<IndexPath>
    let didTapBannerCell: Observable<IndexPath>
    let didTapBackButton: Observable<Void>
    let didSearchBook: Observable<String>
  }
  
  struct Output {
    let reloadData   = PublishRelay<Void>()
    let isLoading    = BehaviorRelay<Bool>(value: true)
    let errorMessage = PublishRelay<HaramError>()
  }
  
  init(dependency: Dependency) {
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.inquireLibrary(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didSearchBook
      .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .subscribe(with: self) { owner, searchQuery in
        owner.dependency.coordinator.showLibraryResultViewController(searchQuery: searchQuery)
      }
      .disposed(by: disposeBag)
    
    input.didTapLibraryCell
      .subscribe(with: self) { owner, indexPath in
        let path: Int
        switch BookType.allCases[indexPath.section] {
        case .new:
          path = owner.newBookModel[indexPath.row].path
        case .popular:
          path = owner.bestBookModel[indexPath.row].path
        case .rental:
          path = owner.rentalBookModel[indexPath.row].path
        }
        owner.dependency.coordinator.showLibraryDetailViewController(path: path)
      }
      .disposed(by: disposeBag)
    
    input.didTapBannerCell
      .subscribe(with: self) { owner, indexPath in
        guard let bannerImageURL = owner.bannerModel[indexPath.row] else {
          owner.dependency.coordinator.showAlert(message: "해당 이미지는 확대할 수 없습니다")
          return
        }
        owner.dependency.coordinator.showZoomImageViewController(imageURL: bannerImageURL)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension BookListViewModel {
  func inquireLibrary(output: Output) {
    dependency.libraryRepository.inquireLibrary()
      .subscribe(with: self, onSuccess: { owner, response in
        owner.newBookModel = response.newBook.map { LibraryCollectionViewCellModel(bookInfo: $0) }
        owner.bestBookModel = response.bestBook.map { LibraryCollectionViewCellModel(bookInfo: $0) }
        owner.rentalBookModel = response.rentalBook.map { LibraryCollectionViewCellModel(bookInfo: $0) }
        owner.bannerModel = response.image.map { URL(string: $0) }

        output.reloadData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
}
