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
  func uploadImage(image: UIImage, type: AggregateType)
  
  var successUploadImage: Signal<(UploadImageResponse, UIImage)> { get }
  var successCreateBoard: Signal<Void> { get }
}

final class EditBoardViewModel {
  
  private let disposeBag = DisposeBag()
  private let boardRepository: BoardRepository
  private let imageRepository: ImageRepository
  
  private var tempFileList: [FileRequeset] = []
  private let successUploadImageRelay = PublishRelay<(UploadImageResponse, UIImage)>()
  private let successCreateBoardRelay = PublishRelay<Void>()
  
  init(boardRepository: BoardRepository = BoardRepositoryImpl(), imageRepository: ImageRepository = ImageRepositoryImpl()) {
    self.boardRepository = boardRepository
    self.imageRepository = imageRepository
  }
  
}

extension EditBoardViewModel: EditBoardViewModelType {
  var successCreateBoard: RxCocoa.Signal<Void> {
    successCreateBoardRelay.asSignal()
  }
  

  var successUploadImage: Signal<(UploadImageResponse, UIImage)> {
    successUploadImageRelay.asSignal()
  }
  
  func uploadImage(image: UIImage, type: AggregateType = .board) {
    imageRepository.uploadImage(image: image, request: .init(aggregateType: type))
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
          print("오류발생했어 \(error.description)")
        }
      }
      .disposed(by: disposeBag)
  }
  
  func createBoard(categorySeq: Int, title: String, contents: String, isAnonymous: Bool) {
    
    guard !title.isEmpty && !contents.isEmpty else { return }
    print("게시글제목 \(title)")
    print("게시글내용 \(contents)")
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
      print("게시글생성성공 \(response)")
      owner.successCreateBoardRelay.accept(())
    }, onFailure: { owner, error in
      print("에러 \(error.localizedDescription)")
    })
    .disposed(by: disposeBag)
  }
  
  
}
