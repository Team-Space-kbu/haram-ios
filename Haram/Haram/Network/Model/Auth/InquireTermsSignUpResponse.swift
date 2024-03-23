//
//  InquireTermsSignUpResponse.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import Foundation

struct InquireTermsSignUpResponse: Decodable {
  let termsSeq: Int
  let title: String
  let content: String
  let isRequired: Bool
}
