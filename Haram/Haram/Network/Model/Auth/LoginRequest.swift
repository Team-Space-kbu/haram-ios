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
  let deviceInfo: DeviceInfo
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case password = "userPassword"
    case uuid, deviceInfo
  }
}

struct DeviceInfo: Encodable {
  let maker: String
  let model: String
  let osType: OSType
  let osVersion: String
}

enum OSType: String, Encodable {
  case IOS
  case ANDROID
}
