//
//  LoginRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import Foundation

struct LoginRequest: Codable {
  let userID: String
  let password: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case password
  }
}
