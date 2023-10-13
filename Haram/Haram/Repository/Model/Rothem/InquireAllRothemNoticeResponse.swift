//
//  InquireAllRothemNoticeResponse.swift
//  Haram
//
//  Created by 이건준 on 10/13/23.
//

import Foundation

struct InquireAllRothemNoticeResponse: Codable {
  let noticeSeq: Int
  let thumbnailImage: String
  let adminName: String
  let title: String
  let content: String
}
