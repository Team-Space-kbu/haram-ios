//
//  InquireNoticeDetailInfoRequest.swift
//  Haram
//
//  Created by 이건준 on 2/21/24.
//

import Foundation

struct InquireNoticeDetailInfoRequest: Encodable {
  let type: NoticeType
  let path: String
}
