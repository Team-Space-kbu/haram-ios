//
//  InquireRothemRoomInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 10/24/23.
//

import Foundation

struct InquireRothemRoomInfoResponse: Decodable {
  let roomResponse: RothemDetailRoomResponse
  let roomFileResponses: [RoomFileResponse]
  let amenityResponses: [AmenityResponse]
}

struct RothemDetailRoomResponse: Decodable {
  let roomName: String
  let location: String
  let modifiedBy: String
  let modifiedAt: String
  let peopleCount: Int
  let roomExplanation: String
  let thumbnailPath: String
  let roomSeq: Int
  let createdBy: String
  let createdAt: String
}

struct RoomFileResponse: Decodable {
  let seq: Int
  let roomSeq: Int
  let sortNum: Int
  let filePath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}

struct AmenityResponse: Decodable {
  let amenitySeq: Int
  let title: String
  let filePath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}
