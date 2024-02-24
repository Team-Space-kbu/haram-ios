//
//  InquireChapterToBibleRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/09/12.
//

import Foundation

struct InquireChapterToBibleRequest: Encodable {
  let bibleType: BibleType
  let book: String
  let chapter: Int
}

/// 성경검색을 위한 성경타입
enum BibleType: String, Encodable {
  case RT
  case KT
}
