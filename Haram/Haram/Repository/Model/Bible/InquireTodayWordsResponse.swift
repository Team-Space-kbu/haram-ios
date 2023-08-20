//
//  InquireTodayWordsResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import Foundation

struct InquireTodayWordsResponse: Codable {
  let book: Int
  let chapter: Int
  let verse: Int
  let content: String
}
