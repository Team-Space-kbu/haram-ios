//
//  SignupMemberRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/08/02.
//

import Foundation

struct SignupMemberRequest: Codable {
  let userID: String
  let email: String
  let password: String
  let nickname: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case email, password, nickname
  }
}
