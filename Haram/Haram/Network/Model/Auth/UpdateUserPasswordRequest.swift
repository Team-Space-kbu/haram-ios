//
//  UpdateUserPasswordRequest.swift
//  Haram
//
//  Created by 이건준 on 3/27/24.
//

import Foundation

struct UpdateUserPasswordRequest: Encodable {
  let oldPassword: String
  let newPassword: String
}
