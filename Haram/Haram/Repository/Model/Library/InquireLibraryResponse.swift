//
//  InquireLibraryResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Foundation

struct InquireLibraryResponse: Codable {
  let image: String?
  let newBook: [NewBook]
  let bestBook: [BestBook]
  
  enum CodingKeys: String, CodingKey {
    case image, newBook, bestBook
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    image = try values.decodeIfPresent(String.self, forKey: .image)
    newBook = try values.decodeIfPresent([NewBook].self, forKey: .newBook) ?? []
    bestBook = try values.decodeIfPresent([BestBook].self, forKey: .bestBook) ?? []
  }
}

struct NewBook: Codable {
  let url: String
  let image: String
  let title: String
}

struct BestBook: Codable {
  let url: String
  let image: String
  let title: String
}

