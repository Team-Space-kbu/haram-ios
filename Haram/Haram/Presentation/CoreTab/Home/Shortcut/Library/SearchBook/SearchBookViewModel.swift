import Foundation

import RxSwift
import RxCocoa

final class SearchBookViewModel: ViewModelType {
  
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  private var isLoading = false
  
  /// 요청한 페이지
  private var startPage = 1
  
  /// 마지막 페이지
  private var endPage = 2
  
  private(set) var searchResults: [LibraryResultsCollectionViewCellModel] = []
  
  struct Payload {
    let searchQuery: String
  }
  
  struct Dependency {
    let libraryRepository: LibraryRepository
    let coordinator: SearchBookCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didScrollToBottom: Observable<Void>
    let didTapBookResultCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let reloadData = PublishRelay<Void>()
    let errorMessage = PublishRelay<HaramError>()
    let isBookResultEmpty = PublishRelay<Bool>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.didScrollToBottom
    )
    .subscribe(with: self) { owner, _ in
      owner.searchBook(output: output)
    }
    .disposed(by: disposeBag)
    
    input.didConnectNetwork
      .subscribe(with: self) { owner, _ in
        owner.searchBook(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapBookResultCell
      .subscribe(with: self) { owner, indexPath in
        let path = owner.searchResults[indexPath.row].path
        owner.dependency.coordinator.showLibraryDetailViewController(path: path)
      }
      .disposed(by: disposeBag)
    return output
  }
}

extension SearchBookViewModel {
  private func searchBook(output: Output) {
    guard startPage <= endPage && !isLoading else { return }
    
    isLoading = true
    
    dependency.libraryRepository.searchBook(
      query: payload.searchQuery,
      page: startPage
    )
    .subscribe(with: self, onSuccess: { owner, response in
      let model = response.result.map { LibraryResultsCollectionViewCellModel(
        result: $0,
        isLast: false
      ) }
      
      var currentResultModel = owner.searchResults
      currentResultModel.append(contentsOf: model)
      
      owner.searchResults = currentResultModel.enumerated().map { index, result in
        var result = result
        result.isLast = currentResultModel.count - 1 == index
        return result
      }
      
      owner.startPage = response.start + 1
      owner.endPage = response.end
      output.isBookResultEmpty.accept(response.result.isEmpty)
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      if error == .networkError {
        output.errorMessage.accept(.networkError)
        return
      }
      output.isBookResultEmpty.accept(true)
    }, onDisposed: { owner in
      output.reloadData.accept(())
      owner.isLoading = false
    })
    .disposed(by: disposeBag)
  }
}
