//
//  CreateCommentRequest.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import Foundation

struct CreateCommentRequest: Encodable {
  let boardSeq: Int
  let userID: String
  let commentContent: String
  
  enum CodingKeys: String, CodingKey {
    case boardSeq
    case userID = "userId"
    case commentContent
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.boardSeq, forKey: .boardSeq)
    try container.encode(self.userID, forKey: .userID)
    try container.encode(self.commentContent, forKey: .commentContent)
  }
}
