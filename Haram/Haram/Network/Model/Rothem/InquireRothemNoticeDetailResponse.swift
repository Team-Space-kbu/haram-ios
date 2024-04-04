//
//  InquireRothemNoticeDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

struct InquireRothemNoticeDetailResponse: Decodable {
  let noticeResponse: NoticeResponse
  let noticeFileResponses: [NoticeFileResponse]
}

struct NoticeFileResponse: Decodable {
  let seq: Int
  let noticeSeq: Int
  let sortNum: Int
  let filePath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
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
