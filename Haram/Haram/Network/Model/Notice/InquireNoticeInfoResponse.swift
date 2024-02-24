//
//  InquireNoticeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import Foundation

struct InquireNoticeInfoResponse: Decodable {
  let start: String
  let end: String
  let notices: [NoticeInfo]
}

struct NoticeInfo: Decodable {
  let title: String
  let name: String
  let regDate: String
  let path: String
  let loopnum: [String]
  
  enum CodingKeys: String, CodingKey {
    case title, name, path, loopnum
    case regDate = "reg_date"
  }
}
