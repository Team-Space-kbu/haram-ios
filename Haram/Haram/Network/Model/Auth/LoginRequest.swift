//
//  LoginRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import Foundation

struct LoginRequest: Encodable {
  let userID: String
  let password: String
  let uuid: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case password = "userPassword"
    case uuid
  }
}
