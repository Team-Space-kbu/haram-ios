//
//  EditBoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 3/9/24.
//

import UIKit

import RxSwift
import RxCocoa

protocol EditBoardViewModelType {
  
  func createBoard(categorySeq: Int, title: String, contents: String, isAnonymous: Bool)
  func uploadImage(images: [(UIImage, String)], type: AggregateType)
  
  var successUploadImage: Signal<(UploadImageResponse, UIImage)> { get }
  var successCreateBoard: Signal<Void> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class EditBoardViewModel {
  
  private let disposeBag = DisposeBag()
  private let boardRepository: BoardRepository
  private let imageRepository: ImageRepository
  
  private var tempFileList: [FileRequeset] = []
  private let successUploadImageRelay = PublishRelay<(UploadImageResponse, UIImage)>()
  private let successCreateBoardRelay = PublishRelay<Void>()
  private let errorMessageRelay = BehaviorRelay<HaramError?>(value: nil)
  private var isLoading = false
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl(), imageRepository: ImageRepository = ImageRepositoryImpl()) {
    self.boardRepository = boardRepository
    self.imageRepository = imageRepository
  }
  
}

extension EditBoardViewModel: EditBoardViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.compactMap { $0 }.asSignal(onErrorSignalWith: .empty())
  }
  
  var successCreateBoard: RxCocoa.Signal<Void> {
    successCreateBoardRelay.asSignal()
  }
  

  var successUploadImage: Signal<(UploadImageResponse, UIImage)> {
    successUploadImageRelay.asSignal()
  }
  
  func uploadImage(images: [(UIImage, String)], type: AggregateType = .board) {

    isLoading = true
    
    for (image, fileName) in images {
      imageRepository.uploadImage(image: image, request: .init(aggregateType: type), fileName: fileName.replacingOccurrences(of: "/", with: "-") + ".jpeg")
        .subscribe(with: self) { owner, result in
          switch result {
          case .success(let response):
            owner.tempFileList.append(.init(
              tempFilePath: response.tempFilePath,
              fileName: response.fileName,
              fileExt: response.fileExt,
              fileSize: response.fileSize,
              sortNum: 1
            ))
            owner.successUploadImageRelay.accept((response, image))
          case .failure(let error):
            owner.errorMessageRelay.accept(error)
          }
        }
        .disposed(by: disposeBag)
    }
    isLoading = false
  }
  
  func createBoard(categorySeq: Int, title: String, contents: String, isAnonymous: Bool) {
    
    if title == Constants.titlePlaceholder || title.isEmpty {
      errorMessageRelay.accept(.titleIsEmpty)
      return
    } else if contents == Constants.contentPlaceholder || contents.isEmpty {
      errorMessageRelay.accept(.contentsIsEmpty)
      return
    } else if isLoading {
      errorMessageRelay.accept(.uploadingImage)
      return
    }
    
    boardRepository.createBoard(
      categorySeq: categorySeq,
      request: .init(
        title: title,
        contents: contents,
        isAnonymous: isAnonymous,
        fileRequests: tempFileList
      )
    )
    .subscribe(with: self, onSuccess: { owner, response in
      owner.successCreateBoardRelay.accept(())
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      owner.errorMessageRelay.accept(error)
    })
    .disposed(by: disposeBag)
  }
}

extension EditBoardViewModel {
  enum Constants {
    static let titlePlaceholder = "제목을 입력해주세요"
    static let contentPlaceholder = "내용을 입력해주세요"
  }
}
