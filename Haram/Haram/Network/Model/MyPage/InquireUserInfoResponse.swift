//
//  InquireUserInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Foundation

struct InquireUserInfoResponse: Decodable {
  let userID: String
  let userEmail: String
  let userNickname: String
  let role: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case role = "userRole"
    case userEmail, userNickname
  }
}
