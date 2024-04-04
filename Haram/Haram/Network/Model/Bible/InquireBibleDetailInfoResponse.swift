//
//  InquireBibleDetailInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 4/4/24.
//

import Foundation

struct InquireBibleDetailInfoResponse: Decodable {
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

