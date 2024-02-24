//
//  IntranetLoginRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Foundation

struct IntranetLoginRequest: Encodable {
  let intranetID: String
  let intranetPWD: String
  
  enum CodingKeys: String, CodingKey {
    case intranetID = "userId"
    case intranetPWD = "userPw"
  }
}
