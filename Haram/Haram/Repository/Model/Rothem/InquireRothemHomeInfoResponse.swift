//
//  InquireRothemHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 10/23/23.
//

import Foundation

struct InquireRothemHomeInfoResponse: Decodable {
  let noticeList: [RothemNotice]
  let roomList: [RothemRoom]
  let isReserved: Int
  
  enum CodingKeys: String, CodingKey {
    case noticeList = "noticeResponses"
    case roomList = "roomResponses"
    case isReserved
  }
}

struct RothemRoom: Decodable {
  let roomSeq: Int
  let thumbnailPath: String
  let roomName: String
  let roomExplanation: String
  let peopleCount: Int
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}

struct RothemNotice: Decodable {
  let noticeSeq: Int
  let thumbnailPath: String
  let adminName: String
  let title: String
  let content: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}
