//
//  InquireTodayWordsResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import Foundation

struct InquireTodayWordsResponse: Decodable {
  let book: String
  let chapter: Int
  let verse: Int
  let content: String
}
