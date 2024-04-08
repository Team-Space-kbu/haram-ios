//
//  InquireNoticeDetailInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2/21/24.
//

import Foundation

struct InquireNoticeDetailInfoResponse: Decodable {
  let title: String
  let name: String
  let regDate: String
  let content: String
  
  enum CodingKeys: String, CodingKey {
    case title, name, content
    case regDate = "reg_date"
  }
}
