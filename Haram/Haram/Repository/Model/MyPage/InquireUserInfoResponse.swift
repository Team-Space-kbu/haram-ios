//
//  InquireUserInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Foundation

struct InquireUserInfoResponse: Codable {
  let userID: String
  let userEmail: String
  let userNickname: String
  let userStatus: Bool
  let role: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userEmail, userNickname, userStatus, role
  }
}
