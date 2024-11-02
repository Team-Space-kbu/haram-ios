//
//  InquireBoardResponse.swift
//  Haram
//
//  Created by 이건준 on 10/23/23.
//

import Foundation

struct InquireBoardDetailResponse: Decodable {
  let boardSeq: Int
  let title: String
  let contents: String
  let createdBy: String
  let createdAt: String
  let isUpdatable: Bool
  let files: [BoardFile]
  let comments: [Comment]?
}

struct Comment: Decodable {
  let seq: Int
  let contents: String
  let createdBy: String?
  let createdAt: String
  let isUpdatable: Bool
}

struct BoardFile: Decodable {
  let seq: Int
  let fileUrl: String
  let sortNum: Int
}
