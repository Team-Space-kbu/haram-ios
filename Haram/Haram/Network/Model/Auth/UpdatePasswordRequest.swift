//
//  UpdatePasswordRequest.swift
//  Haram
//
//  Created by 이건준 on 2/29/24.
//

import Foundation

struct UpdatePasswordRequest: Encodable {
  let newPassword: String
  let authCode: String
}
