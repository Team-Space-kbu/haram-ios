//
//  InquireRothemNoticeDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

struct InquireRothemNoticeDetailResponse: Decodable {
  let bibleNoticeSeq: Int
  let title: String
  let content: String
  let thumbnailPath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
  let bibleNoticeFileResponses: [BibleNoticeFileResponse]
}

struct BibleNoticeFileResponse: Decodable {
  let seq: Int
  let bibleNoticeSeq: Int
  let sortNum: Int
  let filePath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}
