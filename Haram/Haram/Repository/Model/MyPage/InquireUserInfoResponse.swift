//
//  InquireUserInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Foundation

struct InquireUserInfoResponse: Codable {
  let joinDate: String
  let nickname: String
  let userID: String
  let email: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case joinDate, nickname, email
  }
}
