//
//  LoginResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import Foundation

struct LoginResponse: Decodable {
  let accessToken: String
  let refreshToken: String
}
