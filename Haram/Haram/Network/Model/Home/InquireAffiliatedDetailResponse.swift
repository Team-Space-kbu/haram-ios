//
//  InquireAffiliatedDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

struct InquireAffiliatedDetailResponse: Decodable {
  let tag: String
  let address: String
  let businessName: String
  let benefits: String
  let xCoordinate: String
  let yCoordinate: String
  let description: String
  let image: String
}
