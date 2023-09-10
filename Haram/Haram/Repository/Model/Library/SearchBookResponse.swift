//
//  SearchBookResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/30.
//

import Foundation

struct SearchBookResponse: Codable {
  let start: Int
  let end: Int
  let result: [SearchBookResult]
}

struct SearchBookResult: Codable {
  let title: String
  let description: String
  let imageName: String
  let path: Int
  let isbn: String
  
  enum CodingKeys: String, CodingKey {
    case imageName = "image"
    case description = "etc"
    case title, isbn, path
  }
}
