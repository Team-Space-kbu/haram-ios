//
//  InquireBoardlistResponse.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Foundation

struct InquireBoardListInCategoryResponse: Decodable {
  let categorySeq: Int
  let categoryName: String
  let writeableBoard: Bool
  let writeableAnonymous: Bool
  let boards: [Board]
  let startPage: Int
  let endPage: Int
}

struct Board: Decodable {
  let boardSeq: Int
  let title: String
  let contents: String
  let createdBy: String
}
