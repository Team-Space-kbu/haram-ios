//
//  InquireBoardCategoryResponse.swift
//  Haram
//
//  Created by 이건준 on 2/23/24.
//

import Foundation

struct InquireBoardCategoryResponse: Decodable {
  let categorySeq: Int
  let sortNum: Int
  let categoryName: String
  let writeableBoard: Bool
  let writeableComment: Bool
  let writeableAnonymous: Bool
  let iconUrl: String
}
