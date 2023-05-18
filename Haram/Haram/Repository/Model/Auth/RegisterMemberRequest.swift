//
//  RegisterMemberRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Foundation

struct RegisterMemberRequest: Codable {
  let userID: String
  let email: String
  let password: String
  let nickname: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case email, password, nickname
  }
}
