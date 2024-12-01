import RxSwift
import RxCocoa

protocol LibraryResultsViewModelType {
  var whichSearchText: AnyObserver<String> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  var searchResults: Driver<[LibraryResultsCollectionViewCellModel]> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class LibraryResultsViewModel: LibraryResultsViewModelType {
  
  private let disposeBag = DisposeBag()
  private let libraryRepository: LibraryRepository
  
  let whichSearchText: AnyObserver<String>
  let searchResults:Driver<[LibraryResultsCollectionViewCellModel]>
  let isLoading: Driver<Bool>
  let fetchMoreDatas: AnyObserver<Void>
  let errorMessage: Signal<HaramError>
  
  init(libraryRepository: LibraryRepository = LibraryRepositoryImpl()) {
    self.libraryRepository = libraryRepository
    
    let whichSearchingText = PublishSubject<String>()
    let isLoadingRelay     = BehaviorRelay<Bool>(value: false)
    let searchBookResults  = BehaviorRelay<[LibraryResultsCollectionViewCellModel]>(value: [])
    let currentPageSubject = BehaviorRelay<Int>(value: 1)
    let fetchingDatas      = PublishSubject<Void>()
    let isLastPage         = BehaviorRelay<Int>(value: 1)
    let errorMessageRelay  = BehaviorRelay<HaramError?>(value: nil)
    
    whichSearchText = whichSearchingText.asObserver()
    fetchMoreDatas = fetchingDatas.asObserver()
    errorMessage = errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
    
    let requestSearchBook = Observable.combineLatest(
      whichSearchingText,
      currentPageSubject
    )
      .do(onNext: { _ in isLoadingRelay.accept(true) })
      .flatMapLatest(libraryRepository.searchBook)
    
    requestSearchBook.subscribe(onNext: { response in
      
      
      let model = response.result.map { LibraryResultsCollectionViewCellModel(result: $0, isLast: false) }
      
      var currentResultModel = searchBookResults.value
      currentResultModel.append(contentsOf: model)
      
      searchBookResults.accept(currentResultModel.enumerated().map { index, result in
        var result = result
        result.isLast = currentResultModel.count - 1 == index
        return result
      })
      isLastPage.accept(response.end)
      
      
      isLoadingRelay.accept(false)
    }, onError: { error in
      guard let error = error as? HaramError else { return }
      if error == .networkError {
        errorMessageRelay.accept(.networkError)
        return
      }
      searchBookResults.accept([])
      isLoadingRelay.accept(false)
    })
    .disposed(by: disposeBag)
    
    fetchingDatas
      .filter { _ in currentPageSubject.value < isLastPage.value && !isLoadingRelay.value }
      .subscribe(onNext: { _ in
        let currentPage = currentPageSubject.value
        currentPageSubject.accept(currentPage + 1)
      })
      .disposed(by: disposeBag)
    
    // Output
    searchResults = searchBookResults
      .skip(1)
      .asDriver(onErrorDriveWith: .empty())
    
    isLoading = isLoadingRelay
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
}
