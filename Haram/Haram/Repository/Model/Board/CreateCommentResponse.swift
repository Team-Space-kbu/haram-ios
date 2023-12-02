//
//  CreateCommentResponse.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import Foundation

struct CreateCommentResponse: Decodable {
  let commentSeq: Int
  let boardSeq: Int
  let userID: String
  let commentContent: String
  let createdAt: String
  let modifiedAt: String?
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case commentSeq, boardSeq, commentContent, createdAt, modifiedAt
  }
}
