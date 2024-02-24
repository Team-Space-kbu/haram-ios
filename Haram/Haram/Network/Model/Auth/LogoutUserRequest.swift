//
//  LogoutUserRequest.swift
//  Haram
//
//  Created by 이건준 on 2/3/24.
//

import Foundation

struct LogoutUserRequest: Encodable {
  let userID: String
  let uuid: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case uuid
  }
}
