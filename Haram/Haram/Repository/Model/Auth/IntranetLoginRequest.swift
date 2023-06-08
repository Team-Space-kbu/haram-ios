//
//  IntranetLoginRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Foundation

struct IntranetLoginRequest: Codable {
  let intranetToken: String
  let intranetID: String
  let intranetPWD: String
  
  enum CodingKeys: String, CodingKey {
    case intranetToken = "_token"
    case intranetID = "id"
    case intranetPWD = "pw"
  }
}
