//
//  RegisterMemberRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/05/16.
//

import Foundation

struct SignupUserRequest: Encodable {
  let userID: String
  let email: String
  let password: String
  let nickname: String
  let emailAuthCode: String
  let userTermsRequests: [UserTermsRequest]
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case email = "userEmail"
    case password = "userPassword"
    case nickname = "userNickname"
    case emailAuthCode, userTermsRequests
  }
}

struct UserTermsRequest: Codable {
  let termsSeq: Int
  let termsAgreeYn: String
}
