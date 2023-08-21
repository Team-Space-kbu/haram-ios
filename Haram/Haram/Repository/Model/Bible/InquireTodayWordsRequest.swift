//
//  InquireTodayWordsRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import Foundation

struct InquireTodayWordsRequest: Codable {
  let bibleType: RevisionOfTranslationType
//  let book: String
}

enum RevisionOfTranslationType: String, Codable { // 개역개정 타입
  case rt = "RT"
}
