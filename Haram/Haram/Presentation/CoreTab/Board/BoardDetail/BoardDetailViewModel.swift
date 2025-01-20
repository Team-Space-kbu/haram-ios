//
//  BoardViewModel.swift
//  Haram
//
//  Created by 이건준 on 10/15/23.
//

import RxSwift
import RxCocoa
import Foundation

final class BoardDetailViewModel: ViewModelType {
  private let dependency: Dependency
  private let payload: Payload
  private let disposeBag = DisposeBag()
  
  var writeableAnonymous: Bool {
    payload.writeableAnonymous
  }
  
  var writeableComment: Bool {
    payload.writeableComment
  }
  
  private(set) var commentModel: [BoardDetailCollectionViewCellModel] = []
  private(set) var boardImageModel: [BoardImageCollectionViewCellModel] = []
  
  struct Payload {
    let boardSeq: Int
    let categorySeq: Int
    let writeableAnonymous: Bool
    let writeableComment: Bool
  }
  
  struct Dependency {
    let boardRepository: BoardRepository
    let coordinator: BoardDetailCoordinator
  }
  
  struct Input {
    let viewDidLoad: Observable<Void>
    let didTapBackButton: Observable<Void>
    let didTapDeleteBoardButton: Observable<Void>
    let didTapDeleteCommentButton: Observable<IndexPath>
    let didTapSendButton: Observable<Void>
    let didEditComment: Observable<String>
    let didTapBannedButton: Observable<Void>
    let didTapReportButton: Observable<ReportTitleType>
    let didTapAnonymousButton: Observable<Void>
    let didTapImageCell: Observable<IndexPath>
    let didConnectNetwork = PublishRelay<Void>()
  }
  
  struct Output {
    let reloadBoardData = PublishRelay<Void>()
    let errorMessage = BehaviorRelay<HaramError?>(value: nil)
    let isAnonymous = BehaviorRelay<Bool>(value: false)
    let boardModel = PublishRelay<BoardDetailHeaderViewModel>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    Observable.merge(
      input.viewDidLoad,
      input.didConnectNetwork.asObservable()
    )
      .subscribe(with: self) { owner, _ in
        owner.inquireBoardDetail(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.dependency.coordinator.popViewController()
      }
      .disposed(by: disposeBag)
    
    input.didTapDeleteBoardButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, _ in
        AlertManager.showAlert(
          message: .custom("정말 해당 게시글을 삭제하시겠습니까 ?"),
          actions: [
            DestructiveAlertButton { owner.deleteBoard(output: output) },
            CancelAlertButton()
          ]
        )
      }
      .disposed(by: disposeBag)
    
    input.didTapDeleteCommentButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .subscribe(with: self) { owner, indexPath in
        let boardList = owner.commentModel[indexPath.row]
        let commentSeq = boardList.commentSeq
        AlertManager.showAlert(
          message: .custom("정말 해당 댓글을 삭제하시겠습니까 ?"),
          actions: [
            DestructiveAlertButton { owner.deleteComment(output: output, commentSeq: commentSeq) },
            CancelAlertButton()
          ]
        )
      }
      .disposed(by: disposeBag)
    
    input.didTapSendButton
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditComment,
          output.isAnonymous
        )
      )
      .subscribe(with: self) { owner, result in
        let (boardComment, isAnonymous) = result
        guard boardComment != "댓글추가" else { return }
        
        guard !boardComment.isEmpty else {
          AlertManager.showAlert(
            message: .custom("댓글을 반드시 작성해주세요."),
            actions: [ DefaultAlertButton() ]
          )
          return
        }
        owner.createComment(boardComment: boardComment, isAnonymous: isAnonymous, output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapAnonymousButton
      .withLatestFrom(output.isAnonymous)
      .map { !$0 }
      .bind(to: output.isAnonymous)
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .subscribe(with: self) { owner, reportType in
        owner.reportBoard(output: output, reportType: reportType)
      }
      .disposed(by: disposeBag)
    
    input.didTapBannedButton
      .subscribe(with: self) { owner, _ in
        owner.bannedUser(output: output)
      }
      .disposed(by: disposeBag)
    
    input.didTapImageCell
      .subscribe(with: self) { owner, indexPath in
        guard let imageURL = owner.boardImageModel[indexPath.row].imageURL else {
          AlertManager.showAlert(message: .zoomUnavailable)
          return
        }
        owner.dependency.coordinator.showZoomImageViewController(imageURL: imageURL)
      }
      .disposed(by: disposeBag)
    
    return output
  }
}

extension BoardDetailViewModel {
  func bannedUser(output: Output) {
    dependency.boardRepository.bannedUser(boardSeq: payload.boardSeq)
      .subscribe(with: self, onSuccess: { owner, _ in
        AlertManager.showAlert(
          message: .custom("성공적으로 게시글 작성자를 차단하였습니다."),
          actions: [ DefaultAlertButton { owner.dependency.coordinator.popViewController() } ]
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }

  func deleteBoard(output: Output) {
    dependency.boardRepository.deleteBoard(
      categorySeq: payload.categorySeq,
      boardSeq: payload.boardSeq
    )
      .subscribe(with: self, onSuccess: { owner, _ in
        AlertManager.showAlert(
          message: .custom("성공적으로 게시글이 삭제되었습니다."),
          actions: [ DefaultAlertButton { owner.dependency.coordinator.popViewController() } ]
        )
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  func deleteComment(output: Output, commentSeq: Int) {
    dependency.boardRepository.deleteComment(
      categorySeq: payload.categorySeq,
      boardSeq: payload.boardSeq,
      commentSeq: commentSeq
    )
      .subscribe(with: self, onSuccess: { owner, comments in
        owner.inquireBoardDetail(output: output)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }

  func reportBoard(output: Output, reportType: ReportTitleType) {
    dependency.boardRepository.reportBoard(
      request: .init(
        reportType: .board,
        refSeq: payload.boardSeq,
        reportTitle: reportType,
        content: reportType.title
      )
    ).subscribe(with: self, onSuccess: { owner, _ in
      AlertManager.showAlert(
        message: .custom("성공적으로 신고가 접수되었습니다."),
        actions: [ DefaultAlertButton { owner.dependency.coordinator.popViewController() } ]
      )
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessage.accept(error)
    })
    .disposed(by: disposeBag)
  }

  /// 게시글에 대한 정보를 조회합니다
  func inquireBoardDetail(output: Output) {
    let inquireBoard = dependency.boardRepository.inquireBoardDetail(
      categorySeq: payload.categorySeq,
      boardSeq: payload.boardSeq
    )
    
    inquireBoard
      .subscribe(with: self, onSuccess: { owner, response in
        output.boardModel.accept(BoardDetailHeaderViewModel(
          boardSeq: response.boardSeq, boardTitle: response.title,
          boardContent: response.contents,
          boardDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: response.createdAt) ?? Date(),
          boardAuthorName: response.createdBy,
          isUpdatable: response.isUpdatable
        ))
        owner.boardImageModel = response.files.map {
          BoardImageCollectionViewCellModel(imageURL: URL(string: $0.fileUrl))
        }
        
        guard let comments = response.comments else {
          owner.commentModel = []
          output.reloadBoardData.accept(())
          return
        }
        owner.commentModel = comments
          .map { comment in
          return BoardDetailCollectionViewCellModel(
            commentSeq: comment.seq, commentAuthorInfoModel: .init(
              commentAuthorName: comment.createdBy ?? "",
              commentDate: DateformatterFactory.dateForISO8601LocalTimeZone.date(from: comment.createdAt) ?? Date(),
              isUpdatable: comment.isUpdatable
            ),
            comment: comment.contents
          )
        }
        output.reloadBoardData.accept(())
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error)
      })
      .disposed(by: disposeBag)
  }

  /// 해당 게시글에 대한 댓글을 생성합니다
  func createComment(boardComment: String, isAnonymous: Bool, output: Output) {
    guard !boardComment.isEmpty else { return }
    dependency.boardRepository.createComment(
      request: .init(
        contents: boardComment,
        isAnonymous: isAnonymous
      ),
      categorySeq: payload.categorySeq,
      boardSeq: payload.boardSeq
    )
      .subscribe(with: self, onSuccess: { owner, response in
        owner.inquireBoardDetail(output: output)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        output.errorMessage.accept(error == .networkError ? .retryError : error)
      })
      .disposed(by: disposeBag)
  }
}

