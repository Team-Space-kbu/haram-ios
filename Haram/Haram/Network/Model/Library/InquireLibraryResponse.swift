//
//  InquireLibraryResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Foundation

struct InquireLibraryResponse: Decodable {
  let image: [String]
  let newBook: [BookInfo]
  let bestBook: [BookInfo]
  let rentalBook: [BookInfo]
  
  enum CodingKeys: String, CodingKey {
    case image, newBook, bestBook, rentalBook
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    image = try values.decodeIfPresent([String].self, forKey: .image) ?? []
    newBook = try values.decodeIfPresent([BookInfo].self, forKey: .newBook) ?? []
    bestBook = try values.decodeIfPresent([BookInfo].self, forKey: .bestBook) ?? []
    rentalBook = try values.decodeIfPresent([BookInfo].self, forKey: .rentalBook) ?? []
  }
}

struct BookInfo: Decodable {
  let path: Int
  let image: String
  let title: String
}


