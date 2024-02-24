//
//  InquireMainNoticeListResponse.swift
//  Haram
//
//  Created by 이건준 on 2/21/24.
//

import Foundation

struct InquireMainNoticeListResponse: Decodable {
  let noticeType: [MainNoticeType]
  let notices: [NoticeInfo]
}

struct MainNoticeType: Decodable {
  let key: NoticeType
  let tag: String
}
