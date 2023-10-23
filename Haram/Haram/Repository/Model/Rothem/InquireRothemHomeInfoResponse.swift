//
//  InquireRothemHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 10/23/23.
//

import Foundation

struct InquireRothemHomeInfoResponse: Codable {
  let noticeList: [RothemNotice]
  let roomList: [RothemRoom]
  let reservation: Bool
}

struct RothemRoom: Codable {
  let roomSeq: Int
  let thumbnailImage: String
  let roomName: String
  let roomExplanation: String
  let peopleCount: Int
  let location: String
}

struct RothemNotice: Codable {
  let noticeSeq: Int
  let thumbnailImage: String
  let adminName: String
  let title: String
  let content: String
}
