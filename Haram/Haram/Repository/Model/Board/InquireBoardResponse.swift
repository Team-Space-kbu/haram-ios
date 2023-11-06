//
//  InquireBoardResponse.swift
//  Haram
//
//  Created by 이건준 on 10/23/23.
//

import Foundation

struct InquireBoardResponse: Decodable {
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

struct CommentDto: Decodable {
  let modifiedAt: String?
  let commentContent: String
  let boardSeq: Int
  let userId: String
  let commentSeq: Int
  let createdAt: String
}

struct BoardFile: Decodable {
  let fileSeq: Int
  let boardSeq: Int
  let path: String
  let sortNum: Int
}
