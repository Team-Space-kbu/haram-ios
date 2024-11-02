//
//  InquireNoticeDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 10/31/24.
//

import Foundation

struct InquireNoticeDetailResponse: Decodable {
  let content: String
  let title: String
  let createdBy: String
  let createdAt: String
  let thumbnailPath: String
}
