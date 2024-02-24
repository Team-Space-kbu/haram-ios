//
//  InquireBibleMainNoticeResponse.swift
//  Haram
//
//  Created by 이건준 on 10/27/23.
//

import Foundation

struct BibleNoticeResponse: Decodable {
  let modifiedBy: String
  let content: String
  let modifiedAt: String
  let title: String
  let createdBy: String
  let thumbnailPath: String
  let createdAt: String
  let bibleNoticeSeq: Int
}
