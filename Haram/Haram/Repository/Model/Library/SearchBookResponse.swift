//
//  SearchBookResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/30.
//

import Foundation

struct SearchBookResponse: Codable {
  let title: String
  let description: String
  let imageName: String
  let bookInfo: String
  let isbn: String
  
  enum CodingKeys: String, CodingKey {
    case imageName = "image"
    case bookInfo = "info"
    case description = "etc"
    case title, isbn
  }
}
