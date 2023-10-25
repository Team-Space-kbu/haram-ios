//
//  InquireRothemRoomInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 10/24/23.
//

import Foundation

struct InquireRothemRoomInfoResponse: Codable {
  let roomSeq: Int
  let thumbnailImage: String?
  let outsideImages: [String]
  let insideImages: [String]
  let roomName: String
  let roomExplanation: String
  let peopleCount: Int
  let location: String
}
