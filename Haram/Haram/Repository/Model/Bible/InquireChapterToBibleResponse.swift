//
//  InquireChapterToBibleResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/09/12.
//

import Foundation

struct InquireChapterToBibleResponse: Decodable {
  let verse: Int
  let chapter: Int
  let book: String
  let content: String
}
