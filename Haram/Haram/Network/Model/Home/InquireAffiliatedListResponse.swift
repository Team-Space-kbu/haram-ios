//
//  InquireAffiliatedListResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import Foundation

struct InquireAffiliatedResponse: Decodable {
  let id: Int
  let businessName: String
  let tag: String
  let imageString: String
  let address: String

  enum CodingKeys: String, CodingKey {
    case id, tag, businessName, address
    case imageString = "image"
  }
}
