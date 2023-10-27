//
//  InquireBibleMainNoticeResponse.swift
//  Haram
//
//  Created by 이건준 on 10/27/23.
//

import Foundation

struct InquireBibleMainNoticeResponse: Codable {
  let bibleNoticeSeq: Int
  let path: String
  let content: String
  let status: Bool
}
