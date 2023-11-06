//
//  InquireChapelListRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Foundation

struct IntranetRequest: Encodable {
  let intranetToken: String
  let xsrfToken: String
  let laravelSession: String
  
  enum CodingKeys: String, CodingKey {
    case intranetToken = "token"
    case xsrfToken = "xsrf_token"
    case laravelSession = "laravel_session"
  }
}
