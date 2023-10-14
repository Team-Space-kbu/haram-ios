//
//  InquireBoardlistResponse.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Foundation

struct InquireBoardlistResponse: Codable {
  let boardSeq: Int
  let boardTitle: String
  let userID: String
  let boardContent: String
  let boardType: String
  let files: String?
  
  enum CodingKeys: String, CodingKey {
    case boardSeq, boardTitle, boardContent, boardType, files
    case userID = "userId"
  }
}
