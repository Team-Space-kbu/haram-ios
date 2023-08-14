//
//  RegisterMemberRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Foundation

struct SignupUserRequest: Codable {
  let userID: String
  let email: String
  let password: String
  let nickname: String
  let emailAuthCode: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case email = "userEmail"
    case password = "userPassword"
    case nickname = "userNickname"
    case emailAuthCode
  }
}
