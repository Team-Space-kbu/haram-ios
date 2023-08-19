//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
}

final class BoardListViewModel {
  
  private let boardListModelRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  
  init() {
    boardListModelRelay.accept([
      .init(title: "게시판제목1", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과", "간호학과"]),
      .init(title: "게시판제목2", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목3", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목4", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목5", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목6", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목7", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목8", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목9", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
      .init(title: "게시판제목10", subTitle: "게시판부제목", boardType: ["컴퓨터소프트웨어학과"]),
    ])
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    boardListModelRelay.asDriver()
  }
}
