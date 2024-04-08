//
//  RegisterMemberResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Foundation

struct RegisterMemberResponse: Decodable {
  let joinDate: String
  let nickname: String
  let userID: String
  let email: String
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case joinDate, nickname, email
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    joinDate = try values.decodeIfPresent(String.self, forKey: .joinDate) ?? ""
    nickname = try values.decodeIfPresent(String.self, forKey: .nickname) ?? ""
    userID = try values.decodeIfPresent(String.self, forKey: .userID) ?? ""
    email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
  }
}
