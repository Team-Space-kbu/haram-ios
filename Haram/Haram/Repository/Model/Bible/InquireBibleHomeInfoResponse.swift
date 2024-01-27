//
//  InquireBibleHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 1/28/24.
//

import Foundation

struct InquireBibleHomeInfoResponse: Decodable {
  let bibleRandomVerse: BibleRandomVerse
  let bibleNoticeResponses: [InquireBibleMainNoticeResponse]
}

struct BibleRandomVerse: Decodable {
  let bookName: String
  let verse: Int
  let chapter: Int
  let content: String
}
