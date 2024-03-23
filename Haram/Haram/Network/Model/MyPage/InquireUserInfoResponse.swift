//
//  InquireUserInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import Foundation

struct InquireUserInfoResponse: Decodable {
  let userID: String
  let userEmail: String
  let userNickname: String
  let role: String
  let userTermsApiResponses: [UserTermsApiResponse]
  
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case role = "userRole"
    case userEmail, userNickname, userTermsApiResponses
  }
}

struct UserTermsApiResponse: Decodable {
  let seq: Int
  let userSeq: Int
  let termsSeq: Int
  let termsAgreeYn: String
  let title: String
  let content: String
  let isRequired: Bool
}
