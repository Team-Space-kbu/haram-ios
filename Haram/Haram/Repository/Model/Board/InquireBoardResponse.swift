//
//  InquireBoardResponse.swift
//  Haram
//
//  Created by 이건준 on 10/23/23.
//

import Foundation

struct InquireBoardResponse: Codable {
  let boardSeq: Int
  let boardTitle: String
  let userId: String
  let boardContent: String
  let boardFileList: [BoardFile]
  let createdAt: String
  let modifiedAt: String?
  let boardType: BoardType
  let commentDtoList: [CommentDto]
}

struct CommentDto: Codable {
  let modifiedAt: String?
  let commentContent: String
  let boardSeq: Int
  let userId: String
  let commentSeq: Int
  let createdAt: String
}

struct BoardFile: Codable {
  let fileSeq: Int
  let boardSeq: Int
  let path: String
  let sortNum: Int
}
